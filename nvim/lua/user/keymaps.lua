local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
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
-- toggle left explorer
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)
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
		f = {
			name = "+file",
			b = {
				"<cmd>lua require 'telescope.builtin'.buffers(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				"buffers",
				noremap = true,
				silent = true,
			},
			e = { "<cmd>lua require 'telescope.builtin'.symbols()<cr>", "emojis", noremap = true, silent = true },
			G = { "<cmd>lua require 'telescope.builtin'.symbols{sources = {'gitmoji'}}<cr>", "gitmoji", noremap = true, silent = true },
			E = { "<cmd>lua require 'telescope.builtin'.registers()<cr>", "registers", noremap = true, silent = true },
			f = {
				"<cmd>lua require 'telescope.builtin'.find_files(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				"files",
				noremap = true,
				silent = true,
			},
			g = {
				"<cmd>lua require 'telescope.builtin'.live_grep(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				"live grep",
				noremap = true,
				silent = true,
			},
			w = {
				"<cmd>lua require 'telescope.builtin'.grep_string(require('telescope.themes').get_ivy({ previewer = false, layout_config = { width = 0.75 } }))<cr>",
				"grep string",
				noremap = true,
				silent = true,
			},
			h = { "<cmd>lua require 'telescope.builtin'.help_tags()<cr>", "help tags", noremap = true, silent = true },
			j = { "<cmd>lua require 'telescope.builtin'.jumplist()<cr>", "jumplist", noremap = true, silent = true },
			l = { "<cmd>lua require 'telescope.builtin'.loclist()<cr>", "loclist", noremap = true, silent = true },
			r = { "<cmd>lua require 'telescope.builtin'.resume()<cr>", "resume", noremap = true, silent = true },
			q = { "<cmd>lua require 'telescope.builtin'.quickfix()<cr>", "quickfix", noremap = true, silent = true },
			m = { "<cmd>Telescope harpoon marks<cr>", "harpoon marks", noremap = true, silent = true },
		},
		m = {
			"<cmd>Make<cr>",
			"Make",
			noremap = true,
			silent = true,
		},
		z = {
      name = "+zen",
      f = { "<cmd>TZFocus<cr>", "focus", noremap = true, silent = true },
    },
		x = {
			name = "+trouble",
			x = { "<cmd>Trouble<cr>", "trouble", noremap = true, silent = true },
			t = { "<cmd>TroubleToggle<cr>", "trouble toggle", noremap = true, silent = true },
			w = { "<cmd>Trouble workspace_diagnostics<cr>", "workspace diagnostics", noremap = true, silent = true },
			d = { "<cmd>Trouble document_diagnostics<cr>", "document diagnostics", noremap = true, silent = true },
			l = { "<cmd>Trouble loclist<cr>", "loclist", noremap = true, silent = true },
			q = { "<cmd>Trouble quickfix<cr>", "quickfix", noremap = true, silent = true },
			r = { "<cmd>Trouble lsp_references<cr>", "quickfix", noremap = true, silent = true },
		},
		h = {
			name = "+harpoon",
			h = {
				"<cmd>:lua require('harpoon.ui').toggle_quick_menu()<cr>",
				"toggle menu",
				noremap = true,
				silent = true,
			},
			a = { "<cmd>:lua require('harpoon.mark').add_file()<cr>", "add file", noremap = true, silent = true },
			n = { "<cmd>:lua require('harpoon.ui').nav_next()<cr>", "nav next", noremap = true, silent = true },
			n = { "<cmd>:lua require('harpoon.ui').nav_prev()<cr>", "nav prev", noremap = true, silent = true },
			["1"] = { "<cmd>:lua require('harpoon.ui').nav_file(1)<cr>", "nav 1", noremap = true, silent = true },
			["2"] = { "<cmd>:lua require('harpoon.ui').nav_file(2)<cr>", "nav 2", noremap = true, silent = true },
			["3"] = { "<cmd>:lua require('harpoon.ui').nav_file(3)<cr>", "nav 3", noremap = true, silent = true },
			["4"] = { "<cmd>:lua require('harpoon.ui').nav_file(4)<cr>", "nav 4", noremap = true, silent = true },
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
keymap("n", "<leader>s", ":wa<cr>", opts)
-- Buffers
keymap("n", "<leader>bc", ":%bdelete|edit#|bdelete#<cr>", opts) -- close all other buffers

-- Insert
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)
