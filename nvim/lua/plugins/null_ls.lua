return {
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("null-ls").setup({
				debug = true,
				sources = {
					require("null-ls").builtins.formatting.black,
					require("null-ls").builtins.formatting.clang_format,
				},
			})
		end,
	},
}
