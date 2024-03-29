return {
	{
    enabled = true,
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		cmd = "Neotree",
		keys = {
			{ "<leader>e", ":Neotree toggle<cr>", desc = "toggle file tree" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
			require("neo-tree").setup({
				filesystem = {
					follow_current_file = true,
				},
			})
		end,
	},
}
