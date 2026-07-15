-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Navigate seamlessly between nvim splits and tmux panes. These override
-- LazyVim's default <C-h/j/k/l> window-navigation maps (this file loads after
-- the LazyVim defaults). The plugin + tmux side are set up in
-- lua/plugins/core.lua and ~/.tmux.conf respectively.
local map = vim.keymap.set
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Go to Left Window / tmux pane" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Go to Lower Window / tmux pane" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Go to Upper Window / tmux pane" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Go to Right Window / tmux pane" })
