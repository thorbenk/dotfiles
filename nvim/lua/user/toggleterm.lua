-- local status_ok, toggleterm = pcall(require, "toggleterm")
-- if not status_ok then
-- 	return
-- end
-- 
-- -- vim.api.nvim_del_keymap("n", [[<c-\>]])
-- 
-- local M = {}
-- 
-- M.goto_file_linenumber = function()
-- 	local cursor = vim.api.nvim_win_get_cursor(0)
-- 	local bufnr = vim.api.nvim_get_current_buf()
-- 	require("toggleterm").toggle(0)
-- 	vim.api.nvim_win_set_buf(0, bufnr)
-- 	vim.api.nvim_win_set_cursor(0, cursor)
-- 	vim.api.nvim_buf_del_keymap(0, "n", "gF")
-- 	vim.cmd("norm gF")
-- end
-- 
-- M.goto_file = function()
-- 	local cursor = vim.api.nvim_win_get_cursor(0)
-- 	local bufnr = vim.api.nvim_get_current_buf()
-- 	require("toggleterm").toggle(0)
-- 
-- 	local file = io.open("/tmp/d.txt", "a")
-- 	io.output(file)
-- 	io.write("goto_file: cursor=" .. vim.inspect(cursor) .. ", bufnr=" .. vim.inspect(bufnr))
-- 	io.close(file)
-- 
-- 	vim.api.nvim_win_set_buf(0, bufnr)
-- 	vim.api.nvim_win_set_cursor(0, cursor)
-- 	vim.api.nvim_buf_del_keymap(0, "n", "gf")
-- 	vim.cmd("norm gf")
-- end
-- 
-- toggleterm.setup({
-- 	size = 20,
-- 	open_mapping = [[<c-t>]],
-- 	hide_numbers = true,
-- 	shade_filetypes = {},
-- 	shade_terminals = true,
-- 	shading_factor = 2,
-- 	start_in_insert = true,
-- 	insert_mappings = true,
-- 	persist_size = true,
-- 	direction = "float",
-- 	close_on_exit = true,
-- 	shell = vim.o.shell,
-- 	float_opts = {
-- 		border = "curved",
-- 		winblend = 0,
-- 		highlights = {
-- 			border = "Normal",
-- 			background = "Normal",
-- 		},
-- 	},
-- })
-- 
-- function _G.set_terminal_keymaps()
-- 	local opts = { noremap = true }
-- 	vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "n", "gF", [[<cmd>lua require'user.toggleterm'.goto_file_linenumber()<cr>]], opts)
-- 	vim.api.nvim_buf_set_keymap(0, "n", "gf", [[<cmd>lua require'user.toggleterm'.goto_file()<cr>]], opts)
-- end
-- 
-- vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
-- 
-- local Terminal = require("toggleterm.terminal").Terminal
-- local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
-- 
-- function _LAZYGIT_TOGGLE()
-- 	lazygit:toggle()
-- end
-- 
-- local node = Terminal:new({ cmd = "node", hidden = true })
-- 
-- function _NODE_TOGGLE()
-- 	node:toggle()
-- end
-- 
-- local ncdu = Terminal:new({ cmd = "ncdu", hidden = true })
-- 
-- function _NCDU_TOGGLE()
-- 	ncdu:toggle()
-- end
-- 
-- local htop = Terminal:new({ cmd = "htop", hidden = true })
-- 
-- function _HTOP_TOGGLE()
-- 	htop:toggle()
-- end
-- 
-- local python = Terminal:new({ cmd = "python", hidden = true })
-- 
-- function _PYTHON_TOGGLE()
-- 	python:toggle()
-- end
-- 
-- return M
