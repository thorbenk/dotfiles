return {
	{
		"stevearc/overseer.nvim",
		dependencies = {
			"rcarriga/nvim-notify",
			"stevearc/dressing.nvim",
		},
		config = function()
			require("overseer").setup()

			vim.api.nvim_create_user_command("OverseerRestartLast", function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true })
				if vim.tbl_isempty(tasks) then
					vim.notify("No tasks found", vim.log.levels.WARN)
				else
					vim.cmd("wa")
					overseer.run_action(tasks[1], "restart")
				end
			end, {})
			vim.api.nvim_set_keymap("n", "<F1>", ":OverseerRestartLast<cr>", { noremap = true, silent = true })
		end,
	},
}
