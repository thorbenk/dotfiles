local status_ok, true_zen = pcall(require, "true-zen")

vim.g["zen_is_zoomed"] = ""

local zen_tmux_was_zoomed = false

true_zen.setup({
	modes = {
		focus = {
			open_callback = function()
				if os.getenv("TMUX") ~= nil then
					local tmux_is_zoomed = os.execute("tmux list-panes -F '#F' | grep -q Z")
					print("open callback: zoomed=", tmux_is_zoomed)
					if tmux_is_zoomed ~= 0 then
						os.execute("tmux resize-pane -Z")
					else
						zen_tmux_was_zoomed = true
					end
				end
				vim.g["zen_is_zoomed"] = "🔎"
			end,
			close_callback = function()
				if os.getenv("TMUX") ~= nil then
					-- local tmux_is_zoomed = os.execute("tmux list-panes -F '#F' | grep -q Z")
					-- if not zen_tmux_was_zoomed and tmux_is_zoomed ~= 0 then
					--   os.execute("tmux resize-pane -Z")
					-- end
				end
				vim.g["zen_is_zoomed"] = ""
			end,
		},
	},
})
