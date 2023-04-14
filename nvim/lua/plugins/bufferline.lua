return {
	{
		"akinsho/bufferline.nvim",
		lazy = false,
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
		},
		opts = {
			options = {
				max_name_length = 50,
				max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
				tab_size = 21,
				diagnostics = false, -- | "nvim_lsp" | "coc",
				diagnostics_update_in_insert = false,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
		},
	},
}
