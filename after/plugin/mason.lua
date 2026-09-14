local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

-- Mason setup
require("mason").setup({
	registries = {
		"github:Crashdummyy/mason-registry",
		"github:mason-org/mason-registry",
	},
	ui = {
		border = "rounded",
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- Mason tool installer
require("mason-tool-installer").setup({
	ensure_installed = {
		-- LSP servers
		"gdtoolkit",
		"lua-language-server",
		"clangd",
		"pyright",
		"typescript-language-server",
		"json-lsp",
		"html-lsp",
		"css-lsp",
		"tailwindcss-language-server",
		"omnisharp",
		"glsl_analyzer",
		-- Formatters (for null-ls)
		"black",
		"biome",
		"stylua",
		"djlint",
		-- Linters/Diagnostics
		"mypy",
	},
	auto_update = false,
	run_on_start = true,
})

-- Mason LSP config with new vim.lsp.config API
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"clangd",
		"pyright",
		"ts_ls",
		"jsonls",
		"html",
		"cssls",
		"tailwindcss",
		"omnisharp",
		"glsl_analyzer",
	},
	handlers = {
		-- Default handler - uses vim.lsp.config instead of lspconfig
		function(server_name)
			vim.lsp.config(server_name, {
				capabilities = capabilities,
			})
		end,
		-- Custom configurations for specific LSPs
		["lua_ls"] = function()
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_init = function(client)
					local path = client.workspace_folders[1].name
					if not vim.uv.fs_stat(path .. "/.luarc.json") and not vim.uv.fs_stat(path .. "/.luarc.jsonc") then
						client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
							Lua = {
								runtime = {
									version = "LuaJIT",
								},
								workspace = {
									checkThirdParty = false,
									library = {
										vim.env.VIMRUNTIME,
									},
								},
							},
						})
						client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					end
					return true
				end,
			})
		end,

		["ts_ls"] = function()
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				handlers = {
					["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
						severity_sort = true,
						update_in_insert = false,
					}),
				},
				on_attach = function(client, bufnr)
					-- Disable TypeScript LSP formatting (let Biome handle it)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					-- Change unused variable diagnostics to hints
					vim.diagnostic.config({
						severity_sort = true,
						float = { border = "rounded" },
					}, bufnr)
				end,
			})
		end,

		["roslyn"] = function()
			-- Don't use vim.lsp.config for roslyn, use the plugin instead
			require("roslyn").setup({
				config = {
					capabilities = capabilities,
					settings = {
						["csharp|formatting"] = {
							-- EditorConfig support is automatic
						},
					},
					on_attach = function(client, bufnr)
						-- Your keybindings
						vim.keymap.set("n", "<leader>i", function()
							vim.lsp.buf.code_action({
								filter = function(action)
									return action.title:find("using") ~= nil
								end,
								apply = true,
							})
						end, { desc = "Add missing import", buffer = bufnr })
					end,
				},
			})
		end,
		["omnisharp"] = function()
			vim.lsp.config("omnisharp", {
				capabilities = capabilities,
				cmd = { "omnisharp" }, -- Explicitly set the command
				root_dir = vim.fs.root(0, { "godot.project", ".csproj", ".sln", ".git" }),
				settings = {
					FormattingOptions = {
						EnableEditorConfigSupport = true,
						OrganizeImports = false,
					},
					RoslynExtensionsOptions = {
						EnableAnalyzersSupport = true,
						EnableImportCompletion = true,
					},
				},
				on_attach = function(client, bufnr)
					-- Ensure formatting is enabled
					if client.server_capabilities.documentFormattingProvider then
						vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
					end

					vim.keymap.set("n", "<leader>i", function()
						vim.lsp.buf.code_action({
							filter = function(action)
								return action.title:find("using") ~= nil
							end,
							apply = true,
						})
					end, { desc = "Add missing import", buffer = bufnr })

					vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
				end,
			})
		end,
	},
})
vim.lsp.config("pyright", {
	capabilities = capabilities,
	settings = {
		pyright = {
			autoImportCompletion = true,
		},
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
				typeCheckingMode = "strict",
			},
		},
	},
})
vim.lsp.enable("pyright")

-- Global LSP handlers with rounded borders
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gd", "gdscript", "gdscript3" },
	callback = function()
		vim.lsp.start({
			name = "gdscript",
			cmd = { "nc", "127.0.0.1", "6005" },
			root_dir = vim.fs.root(0, { "project.godot", ".git" }),
			capabilities = capabilities,
			filetypes = { "gd", "gdscript", "gdscript3" },
		})
	end,
})
