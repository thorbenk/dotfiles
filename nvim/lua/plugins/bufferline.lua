return {
	{
		"akinsho/bufferline.nvim",
		config = function()
			bufferline = require("bufferline")
			bufferline.setup({
				options = {
					max_name_length = 50,
					max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
					tab_size = 21,
					diagnostics = false, -- | "nvim_lsp" | "coc",
					diagnostics_update_in_insert = false,
				},
			})
		end,
	},
}
