local status_ok, true_zen = pcall(require, "true-zen")

true_zen.setup({
  modes = {
    focus = {
      open_callback = function()
        if os.getenv("TMUX") ~= nil then
          os.execute("tmux resize-pane -Z")
        end
      end,
      close_callback = function()
        if os.getenv("TMUX") ~= nil then
          os.execute("tmux resize-pane -Z")
        end
      end,
    }
  }
})
