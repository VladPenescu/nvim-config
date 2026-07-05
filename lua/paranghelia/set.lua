-------------- General -----------------
vim.opt.nu = true
vim.opt.relativenumber = false
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.mousemoveevent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.lsp.inlay_hint.enable(true)
vim.diagnostic.config({
	virtual_text = true, -- This enables inline error messages
	signs = true, -- Shows signs in the gutter
	underline = true, -- Underlines the text with error
	update_in_insert = false,
	severity_sort = true,
})
vim.lsp.util.make_position_params(nil, "utf-8")
vim.opt.updatetime = 50
vim.g.mapleader = " "
vim.opt.foldlevel = 20
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-------------- KeyBindings -----------------
vim.keymap.set("n", "<leader>pp", vim.cmd.Ex)
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
-- Map Enter to create a new line and stay in Normal mode
vim.keymap.set("n", "<CR>", "o<Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>G", vim.cmd.Git)
----- Docker & Database
vim.keymap.set("n", "<leader>dk", "<cmd>lua docker_client_toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>db", "<cmd>:DBUIToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "q", "b")
vim.keymap.set("n", "Q", "B")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.clear_breakpoints()<CR>")
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F6>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F7>", ":lua require'dap'.step_back()<CR>")
vim.keymap.set("n", "<F9>", ":lua require'dapui'.toggle()<CR>")
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F11>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<F12>", ":lua require'dap'.terminate()<CR>")

-- Your existing Format command (keep as-is)
vim.api.nvim_create_user_command("Format", function()
	-- Try to join with previous undo block
	pcall(vim.cmd, "undojoin")
	vim.lsp.buf.format()
end, {})

-- Your existing keymaps (keep as-is)
vim.keymap.set("n", "<Esc>", ":Format<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<Esc>", "<C-g>u<Esc>:w<CR>:Format<CR>", { noremap = true, silent = true })
-- Ctrl-z && Ctrl-y
vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })
vim.keymap.set("n", "<C-y>", "<C-r>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-y>", "<C-o><C-r>", { noremap = true, silent = true })
-- Restart LSP
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "LSP Restart" })
-- Override default 'u' (undo) to preserve cursor position
vim.keymap.set("n", "u", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	local view = vim.fn.winsaveview()

	vim.cmd("undo")

	local line_count = vim.api.nvim_buf_line_count(0)
	if pos[1] <= line_count then
		local line_length = #vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
		if pos[2] <= line_length then
			vim.api.nvim_win_set_cursor(0, pos)
		else
			vim.api.nvim_win_set_cursor(0, { pos[1], line_length })
		end
	end

	pcall(vim.fn.winrestview, view)
end, { noremap = true, silent = true })
-- vim.keymap.set("n", "dd", '"_dd', { noremap = true })
--
-- Override default Ctrl+R (redo) to preserve cursor position
vim.keymap.set("n", "<C-r>", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	local view = vim.fn.winsaveview()

	vim.cmd("redo")

	local line_count = vim.api.nvim_buf_line_count(0)
	if pos[1] <= line_count then
		local line_length = #vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
		if pos[2] <= line_length then
			vim.api.nvim_win_set_cursor(0, pos)
		else
			vim.api.nvim_win_set_cursor(0, { pos[1], line_length })
		end
	end

	pcall(vim.fn.winrestview, view)
end, { noremap = true, silent = true })
