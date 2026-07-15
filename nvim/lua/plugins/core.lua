return {
  -- Use Catppuccin, matching the tmux + Ghostty theme.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- Seamless navigation between nvim splits and tmux panes with <C-h/j/k/l>.
  -- The tmux side is configured in ~/.tmux.conf (christoomey/vim-tmux-navigator).
  -- Mappings live in lua/config/keymaps.lua so they win over LazyVim's defaults.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },

  -- Python LSP is basedpyright (selected in lua/config/options.lua). It
  -- auto-detects the project's .venv (as created by uv), so no venv-selector
  -- plugin or explicit venv path is needed.
}
