return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"ray-x/lsp_signature.nvim",
				opts = {},
				lazy = false,
			},
			{ "hrsh7th/nvim-cmp", version = false }, -- The completion plugin
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			"saadparwaiz1/cmp_luasnip", -- snippet completions
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
		},
		config = function()
			-- vim.lsp.set_log_level("debug")

			local lspconfig = require("lspconfig")
			require("plugins.lsp.handlers").setup()
			local lsp_status = require("lsp-status")

			lsp_status.register_progress()

			lspconfig.pyright.setup({
				on_attach = require("plugins.lsp.handlers").on_attach,
				capabilities = vim.tbl_extend(
					"keep",
					require("plugins.lsp.handlers").capabilities,
					lsp_status.capabilities
				),
				settings = {
					python = {
						analysis = {
							logLevel = "Trace",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							extraPaths = {
								"/w/src/deeplearningcore/",
								"/w/src/diecastingcreator/",
								"/w/src/ml_toolbox/",
							},
						},
					},
				},
			})

			lspconfig.clangd.setup({
				-- cmd = {"clangd", "--query-driver=/usr/bin/arm-none-eabi-g++"},
				on_attach = require("plugins.lsp.handlers").on_attach,
				capabilities = vim.tbl_extend(
					"keep",
					require("plugins.lsp.handlers").capabilities,
					lsp_status.capabilities
				),
				handlers = lsp_status.extensions.clangd.setup(),
			})
		end,
	},
}
