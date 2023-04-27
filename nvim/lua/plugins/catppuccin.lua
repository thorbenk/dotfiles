return {
	{
		lazy = false,
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				dim_inactive = {
					enabled = true,
				},
			})
		end,
	},
}
