require("user.options")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

require("lazy").setup("plugins")

vim.cmd.colorscheme("catppuccin-macchiato")

require("user.keymaps")
require("user.toggleterm")
require("user.cmp")
require("user.whichkey")
require("user.null_ls")
require("user.floatterm")
require("user.neotest")
require("user.true-zen")
require("user.treesitter-textobjects")
