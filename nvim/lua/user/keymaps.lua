local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.tmux_navigator_no_mappings = 1

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal
-- better window navigation

keymap("n", "<C-h>", ":TmuxNavigateLeft<cr>", opts)
keymap("n", "<C-j>", ":TmuxNavigateDown<cr>", opts)
keymap("n", "<C-k>", ":TmuxNavigateUp<cr>", opts)
keymap("n", "<C-l>", ":TmuxNavigateRight<cr>", opts)
keymap("n", "<C-\\>", ":TmuxNavigatePrevious<cr>", opts)
-- Resize with arrows
keymap("n", "<A-h>", ":TmuxResizeLeft<cr>", opts)
keymap("n", "<A-j>", ":TmuxResizeDown<cr>", opts)
keymap("n", "<A-k>", ":TmuxResizeUp<cr>", opts)
keymap("n", "<A-l>", ":TmuxResizeRight<cr>", opts)
-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
-- Telescope
local wk = require("which-key")
wk.register({
	["<leader>"] = {
		-- m = {
		-- 	"<cmd>Make<cr>",
		-- 	"Make",
		-- 	noremap = true,
		-- 	silent = true,
		-- },
		-- z = {
		-- 	name = "+zen",
		-- 	f = { "<cmd>TZFocus<cr>", "focus", noremap = true, silent = true },
		-- },
		h = {
			name = "+harpoon",
		},
		t = {
			name = "+test",
			r = {
				name = "run",
				n = { "<cmd>:lua require('neotest').run.run()<cr>", "nearest", noremap = true, silent = true },
				c = {
					"<cmd>:lua require('neotest').run.run(vim.fn.expand('%'))<cr>",
					"current file",
					noremap = true,
					silent = true,
				},
			},
			c = { "<cmd>:lua require('neotest').output.open()<cr>", "open output", noremap = true, silent = true },
			s = {
				name = "summary",
				o = { "<cmd>:lua require('neotest').summary.open()<cr>", "open", noremap = true, silent = true },
				c = { "<cmd>:lua require('neotest').summary.close()<cr>", "close", noremap = true, silent = true },
				t = { "<cmd>:lua require('neotest').summary.toggle()<cr>", "toggle", noremap = true, silent = true },
			},
		},
	},
})
-- Quickfix
keymap("n", "<leader>qo", ":copen<cr>", opts)
keymap("n", "<leader>qc", ":cclose<cr>", opts)
-- Saving

-- keymap("n", "<leader>s", ":wa<cr>", opts)

-- Insert
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)
