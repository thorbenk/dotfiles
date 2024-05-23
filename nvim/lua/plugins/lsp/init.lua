local check_backspace = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local kind_icons = {
	Text = "",
	Method = "m",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

return {
	{
    enabled = true,
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					-- log_level = vim.log.levels.TRACE,
					ensure_installed = {
						"debugpy",
					},
				},
			},
			"williamboman/mason-lspconfig.nvim",
			{
				"ray-x/lsp_signature.nvim",
				opts = {},
				lazy = false,
			},
      {
        'linrongbin16/lsp-progress.nvim',
        config = function()
          require('lsp-progress').setup()
        end
      },
			{
        "hrsh7th/nvim-cmp", version = false,
        opts = function(_, opts)
          local cmp = require("cmp")
          -- snippet = {
          -- 	expand = function(args)
          -- 		luasnip.lsp_expand(args.body) -- For `luasnip` users.
          -- 	end,
          -- },
          opts.mapping = {
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
            ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
            ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
            ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ["<C-e>"] = cmp.mapping({
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            }),
            -- Accept currently selected item. If none selected, `select` first item.
            -- Set `select` to `false` to only confirm explicitly selected items.
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              -- elseif luasnip.expandable() then
              -- 	luasnip.expand()
              -- elseif luasnip.expand_or_jumpable() then
              -- 	luasnip.expand_or_jump()
              elseif check_backspace() then
                fallback()
              else
                fallback()
              end
            end, {
              "i",
              "s",
            }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              -- elseif luasnip.jumpable(-1) then
              -- 	luasnip.jump(-1)
              else
                fallback()
              end
            end, {
              "i",
              "s",
            }),
          }

          cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = 'buffer' }
            }
          })
          cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              { name = 'path' }
            }, {
              { name = 'cmdline' }
            })
          })

          opts.formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
              -- Kind icons
              vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
              -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                nvim_lua = "[NVIM_LUA]",
                -- luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
              })[entry.source.name]
              return vim_item
            end,
          }

          opts.sources = {
            { name = "nvim_lsp" },
            { name = "buffer" },
            -- { name = "luasnip" },
            { name = "path" },
          }
          -- experimental = {
          -- 	ghost_text = {
          -- 		hl_group = "LspCodeLens",
          -- 	},
          -- },
        end,
      }, -- The completion plugin
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			-- "saadparwaiz1/cmp_luasnip", -- snippet completions
			"hrsh7th/cmp-nvim-lsp",
			-- "hrsh7th/cmp-nvim-lua",
		},
		config = function()
      -- vim.lsp.set_log_level("trace")

			local lspconfig = require("lspconfig")
			require("plugins.lsp.handlers").setup()

			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = {
					"pyright",
					"clangd",
					"lua_ls",
				},
			})

			lspconfig.pyright.setup({
				on_attach = require("plugins.lsp.handlers").on_attach,
				settings = {
					python = {
						analysis = {
							logLevel = "Error",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
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
				cmd = {
          "clangd",
          -- "--query-driver=/usr/bin/g++-11",
          -- "--log=verbose",
        },
				on_attach = require("plugins.lsp.handlers").on_attach,
				capabilities = vim.tbl_extend(
					"keep",
					{ offsetEncoding = { "utf-16" } },
					require("plugins.lsp.handlers").capabilities
				)
			})

			lspconfig.lua_ls.setup({})
		end,
	},
}
