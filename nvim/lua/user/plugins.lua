local fn = vim.fn

-- Automatically install packer
-- ... goes to ~/.local/share/nvim
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

vim.g["tmux_navigator_save_on_switch"] = 2

-- Install your plugins here
return packer.startup(function(use)
	use("wbthomason/packer.nvim") -- Have packer manage itself
	use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
	use("nvim-lua/plenary.nvim") -- Useful lua functions used by lots of plugins

	-- colors
	-- use "joshdick/onedark.vim"
	use("ful1e5/onedark.nvim")
	use("lunarvim/darkplus.nvim")

	use("tpope/vim-repeat")
	use("tpope/vim-unimpaired")
	use("tpope/vim-dispatch")

	use("christoomey/vim-tmux-navigator")
	use("RyanMillerC/better-vim-tmux-resizer")

	-- cmp plugins
	use("hrsh7th/nvim-cmp") -- The completion plugin
	use("hrsh7th/cmp-buffer") -- buffer completions
	use("hrsh7th/cmp-path") -- path completions
	use("hrsh7th/cmp-cmdline") -- cmdline completions
	use("saadparwaiz1/cmp_luasnip") -- snippet completions
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lua")

	-- snippets
	use("L3MON4D3/LuaSnip") --snippet engine
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- LSP
	use("neovim/nvim-lspconfig") -- enable LSP
	use("ray-x/lsp_signature.nvim")

	-- Telescope
	use("nvim-telescope/telescope.nvim")
	use({
    "natecraddock/telescope-zf-native.nvim",
		requires = {
			"nvim-telescope/telescope.nvim",
		},
		run = "make",
	})
	use({
		"nvim-telescope/telescope-symbols.nvim",
		requires = {
			"nvim-telescope/telescope.nvim",
		},
	})

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
  use('nvim-treesitter/nvim-treesitter-textobjects')

	-- Comment
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	-- Tree
	use("kyazdani42/nvim-web-devicons")
	use("kyazdani42/nvim-tree.lua")

	-- Gitsigns
	use({
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
	})

	use("nvim-lua/lsp-status.nvim")
	use("jose-elias-alvarez/null-ls.nvim")

	-- Status line
	-- use({
	-- 	"feline-nvim/feline.nvim",
	-- })
	use({
		"nvim-lualine/lualine.nvim",
	})

	-- Bufferline
	use("akinsho/bufferline.nvim")
	use("moll/vim-bbye")

	-- Toggleterm
	use("akinsho/toggleterm.nvim")

	-- Whichkey
	use("folke/which-key.nvim")

	use({
		"goolord/alpha-nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	})

	use({
		requires = "kyazdani42/nvim-web-devicons",
		"folke/trouble.nvim",
	})

	use("nvie/vim-flake8")

	use("ThePrimeagen/harpoon")

	use("voldikss/vim-floaterm")

	use({
		"nvim-neotest/neotest",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
	})

	use({
		"nvim-neotest/neotest-python",
		requires = {
			"nvim-neotest/neotest",
		},
	})

  use("Pocco81/true-zen.nvim")
	-- use {
	--   "sunjon/shade.nvim"
	-- }

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
