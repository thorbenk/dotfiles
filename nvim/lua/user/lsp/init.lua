local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

local status_ok, lsp_status = pcall(require, "lsp-status")
if not status_ok then
	return
end

-- TODO
-- Keep popup with signature help open
-- require("lsp_signature").setup()

require("user.lsp.handlers").setup()

lsp_status.register_progress()

lspconfig.pyright.setup({
	on_attach = require("user.lsp.handlers").on_attach,
	capabilities = vim.tbl_extend("keep", require("user.lsp.handlers").capabilities, lsp_status.capabilities),
	settings = {
		python = {
			analysis = {
				logLevel = "Trace",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				extraPaths = {
					"/w/src/deeplearningcore/",
					"/w/src/diecastingcreator/",
					"/w/src/ml_toolbox/",
				},
			},
		},
	},
})

lspconfig.clangd.setup({
	-- cmd = {"clangd", "--query-driver=/usr/bin/arm-none-eabi-g++"},
	on_attach = require("user.lsp.handlers").on_attach,
	capabilities = vim.tbl_extend("keep", require("user.lsp.handlers").capabilities, lsp_status.capabilities),
	handlers = lsp_status.extensions.clangd.setup(),
})
