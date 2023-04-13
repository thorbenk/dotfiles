return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				dim_inactive = {
					enabled = true,
				},
			})
		end,
	},
}
