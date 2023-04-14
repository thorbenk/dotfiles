return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false,
		dependencies = {
			{
				"natecraddock/telescope-zf-native.nvim",
				dependencies = {
					"nvim-telescope/telescope.nvim",
				},
				config = function()
					require("telescope").load_extension("zf-native")
				end,
			},
			{
				"nvim-telescope/telescope-symbols.nvim",
				dependencies = {
					"nvim-telescope/telescope.nvim",
				},
				config = function()
					require("telescope").load_extension("harpoon")
				end,
			},
		},
		keys = {
			{
				"<leader>fb",
				"<cmd>lua require 'telescope.builtin'.buffers(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				desc = "Buffers",
			},
			{ "<leader>fe", "<cmd>lua require 'telescope.builtin'.symbols()<cr>", desc = "emojis" },
			{
				"<leader>fG",
				"<cmd>lua require 'telescope.builtin'.symbols{sources = {'gitmoji'}}<cr>",
				desc = "gitmoji",
			},
			{ "<leader>fE", "<cmd>lua require 'telescope.builtin'.registers()<cr>", desc = "registers" },
			{
				"<leader>ff",
				"<cmd>lua require 'telescope.builtin'.find_files(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				desc = "files",
			},
			{
				"<leader>fg",
				"<cmd>lua require 'telescope.builtin'.live_grep(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				desc = "live grep",
			},
			{
				"<leader>fw",
				"<cmd>lua require 'telescope.builtin'.grep_string(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				desc = "grep string",
			},
			{ "<leader>fh", "<cmd>lua require 'telescope.builtin'.help_tags()<cr>", desc = "help tags" },
			{ "<leader>fj", "<cmd>lua require 'telescope.builtin'.jumplist()<cr>", desc = "jumplist" },
			{ "<leader>fl", "<cmd>lua require 'telescope.builtin'.loclist()<cr>", desc = "loclist" },
			{ "<leader>fr", "<cmd>lua require 'telescope.builtin'.resume()<cr>", desc = "resume" },
			{ "<leader>fq", "<cmd>lua require 'telescope.builtin'.quickfix()<cr>", desc = "quickfix" },
			{ "<leader>fm", "<cmd>Telescope harpoon marks<cr>", desc = "harpoon marks" },
			-- git
			{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
		},
	},
}
