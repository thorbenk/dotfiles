local M = {}

-- TODO: backfill this to template
M.setup = function()
  vim.diagnostic.config({
    signs = {
      text = {
        ["DiagnosticSignError"] = "",
        ["DiagnosticSignWarn"] = "",
        ["DiagnosticSignHint"] = "",
        ["DiagnosticSignInfo"] = ""
      }
    }
	})

	vim.diagnostic.config({
		virtual_text = { spacing = 4 }, -- , prefix = "●" },
		-- show signs
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = false,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	})
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }

	local wk = require("which-key")
	wk.register({
		["<leader>"] = {
			l = {
				name = "+lsp",
				a = {
					"<cmd>lua vim.lsp.buf.code_action()<CR>",
					"code action",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				D = {
					"<cmd>lua vim.lsp.buf.declaration()<cr>",
					"go to decl",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				d = {
					"<cmd>lua require 'telescope.builtin'.lsp_definitions()<cr>",
					"go to def",
					noremap = true,
					silent = true,
				},
				f = {
					"<cmd>lua vim.lsp.buf.format()<cr>",
					"format",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "hover (K)", noremap = true, silent = true, buffer = bufnr },
				H = {
					"<cmd>lua vim.lsp.buf.signature_help()<cr>",
					"signature help",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				i = {
					"<cmd>lua vim.lsp.buf.implementation()<cr>",
					"implementation",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				l = {
					'<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<cr>',
					"line diag",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				n = {
					'<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<cr>',
					"diag next",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				o = {
					"<cmd>lua vim.diagnostic.open_float()<CR>",
					"diagnostic (float)",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				p = {
					'<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<cr>',
					"diag prev",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				q = {
					"<cmd>lua vim.diagnostic.setloclist()<cr>",
					"set loclist",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				r = {
					"<cmd>lua require 'telescope.builtin'.lsp_references()<cr>",
					"references",
					noremap = true,
					silent = true,
				},
				R = { "<cmd>lua vim.lsp.buf.rename()<CR>", "rename", noremap = true, silent = true, buffer = bufnr },
				s = {
					"<cmd>lua require'telescope.builtin'.lsp_document_symbols{}<cr>",
					"doc symbols",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				S = {
					"<cmd>lua require'telescope.builtin'.lsp_dynamic_workspace_symbols{}<cr>",
					"ws symbols",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
				t = {
					"<cmd>ClangdSwitchSourceHeader<cr>",
					"source<->header",
					noremap = true,
					silent = true,
					buffer = bufnr,
				},
			},
		},
	})

	vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

	-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"gl",
		'<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>',
		opts
	)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
	vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])
end

M.on_attach = function(client, bufnr)
	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false
	end
	lsp_keymaps(bufnr)
end

M.capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

return M
