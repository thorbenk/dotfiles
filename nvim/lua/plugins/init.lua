return {
	"nvim-lua/popup.nvim", -- An implementation of the Popup API from vim in Neovim
	"nvim-lua/plenary.nvim", -- Useful lua functions used by lots of plugins

	-- colors
	-- use "joshdick/onedark.vim"
	"ful1e5/onedark.nvim",
	"lunarvim/darkplus.nvim",

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
	"L3MON4D3/LuaSnip", --snippet engine
	"rafamadriz/friendly-snippets", -- a bunch of snippets to use

	-- LSP
	"neovim/nvim-lspconfig", -- enable LSP
	-- "ray-x/lsp_signature.nvim", # TODO

	-- Telescope
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

	"nvim-lua/lsp-status.nvim",
	"jose-elias-alvarez/null-ls.nvim",

	-- Bufferline
	"moll/vim-bbye",

	-- Toggleterm
	"akinsho/toggleterm.nvim",

	-- Whichkey
	"folke/which-key.nvim",

	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	},

	{
		dependencies = "nvim-tree/nvim-web-devicons",
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

	{ "stevearc/dressing.nvim" },
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
			require("notify").setup({})
		end,
	},

	{
		"klen/nvim-config-local",
		config = function()
			require("config-local").setup({
				config_files = { ".nvim.lua" },
			})
		end,
	},
}
