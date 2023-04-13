return {
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			lualine = require("lualine")
			lualine.setup({
				sections = {
					lualine_a = { "g:zen_is_zoomed" },
					lualine_b = { "mode" },
					-- lualine_c = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ "filename", path = 1 },
						"require'lsp-status'.status()",
					},
					lualine_x = {},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{ "filename", path = 1 },
					},
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
			})
		end,
	},
}
