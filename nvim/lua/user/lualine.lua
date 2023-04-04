local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		disabled_filetypes = {},
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { "g:zen_is_zoomed" },
		lualine_b = { "mode" },
		lualine_c = { "branch", "diff", "diagnostics" },
		lualine_d = {
			{ "filename", path = 1 },
			"require'lsp-status'.status()",
		},
		lualine_x = {},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_d = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {},
})
