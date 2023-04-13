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

require("lazy").setup({
	"nvim-lua/popup.nvim", -- An implementation of the Popup API from vim in Neovim
	"nvim-lua/plenary.nvim", -- Useful lua functions used by lots of plugins

	-- colors
	-- use "joshdick/onedark.vim"
	"ful1e5/onedark.nvim",
	"lunarvim/darkplus.nvim",
	{ "catppuccin/nvim", name = "catppuccin" },

	"tpope/vim-repeat",
	"tpope/vim-unimpaired",
	"tpope/vim-dispatch",

	"christoomey/vim-tmux-navigator",
	"RyanMillerC/better-vim-tmux-resizer",

	-- cmp plugins
	"hrsh7th/nvim-cmp", -- The completion plugin
	"hrsh7th/cmp-buffer", -- buffer completions
	"hrsh7th/cmp-path", -- path completions
	"hrsh7th/cmp-cmdline", -- cmdline completions
	"saadparwaiz1/cmp_luasnip", -- snippet completions
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lua",

	-- snippets
	-- "L3MON4D3/LuaSnip", --snippet engine
	-- "rafamadriz/friendly-snippets", -- a bunch of snippets to use

	-- LSP
	"neovim/nvim-lspconfig", -- enable LSP
	-- "ray-x/lsp_signature.nvim", # TODO

	-- Telescope
	"nvim-telescope/telescope.nvim",
	{
		"natecraddock/telescope-zf-native.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
	},
	{
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	"nvim-treesitter/nvim-treesitter-textobjects",

	-- Comment
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Tree
	"kyazdani42/nvim-web-devicons",
	"kyazdani42/nvim-tree.lua",

	-- Gitsigns
	{
		"lewis6991/gitsigns.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	"nvim-lua/lsp-status.nvim",
	"jose-elias-alvarez/null-ls.nvim",

	-- Status line
	-- use({
	-- 	"feline-nvim/feline.nvim",
	-- })
	"nvim-lualine/lualine.nvim",

	-- Bufferline
	"akinsho/bufferline.nvim",
	"moll/vim-bbye",

	-- Toggleterm
	"akinsho/toggleterm.nvim",

	-- Whichkey
	"folke/which-key.nvim",

	{
		"goolord/alpha-nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	},

	{
		dependencies = "kyazdani42/nvim-web-devicons",
		"folke/trouble.nvim",
	},

	-- "nvie/vim-flake8", # TODO

	"ThePrimeagen/harpoon",

	-- "voldikss/vim-floaterm",

	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
	},

	{
		"nvim-neotest/neotest-python",
		dependencies = {
			"nvim-neotest/neotest",
		},
	},

	"Pocco81/true-zen.nvim",
	"sunjon/shade.nvim",

	{ "stevearc/dressing.nvim" },
	{ "rcarriga/nvim-notify" },
	{
		"stevearc/overseer.nvim",
		config = function()
			require("overseer").setup()
		end,
	},
})

require("user.options")
-- require("user.plugins")
require("user.keymaps")
require("user.toggleterm")
require("user.colorscheme")
require("user.cmp")
require("user.lsp")
require("user.telescope")
require("user.treesitter")
require("user.nvim-tree")
require("user.gitsigns")
require("user.lualine")
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
