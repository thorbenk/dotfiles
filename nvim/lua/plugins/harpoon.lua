return {
	{
    enabled = false,
		"ThePrimeagen/harpoon",
		keys = {
			{ "<leader>hh", "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "toggle menu" },
			{ "<leader>ha", "<cmd>:lua require('harpoon.mark').add_file()<cr>", desc = "add file" },
			{ "<leader>hn", "<cmd>:lua require('harpoon.ui').nav_next()<cr>", desc = "nav next" },
			{ "<leader>hn", "<cmd>:lua require('harpoon.ui').nav_prev()<cr>", desc = "nav prev" },
			{ "<leader>h1", "<cmd>:lua require('harpoon.ui').nav_file(1)<cr>", desc = "nav 1" },
			{ "<leader>h2", "<cmd>:lua require('harpoon.ui').nav_file(2)<cr>", desc = "nav 2" },
			{ "<leader>h3", "<cmd>:lua require('harpoon.ui').nav_file(3)<cr>", desc = "nav 3" },
			{ "<leader>h4", "<cmd>:lua require('harpoon.ui').nav_file(4)<cr>", desc = "nav 4" },
		},
	},
}
