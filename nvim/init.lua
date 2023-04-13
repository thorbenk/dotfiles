local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require("user.options")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup("plugins")

-- require("user.plugins")
require("user.keymaps")
require("user.toggleterm")
require("user.colorscheme")
require("user.cmp")
require("user.lsp")
require("user.telescope")
require("user.treesitter")
require("user.bufferline")
require("user.whichkey")
require("user.null_ls")
require("user.trouble")
require("user.floatterm")
-- require("user.feline")
require("user.neotest")
require("user.true-zen")
-- require "user.shade"
require("user.treesitter-textobjects")
