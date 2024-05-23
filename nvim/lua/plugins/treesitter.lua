return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdateSync",
		version = false,
		dependencies = {
			{
				-- 		"nvim-treesitter/nvim-treesitter-textobjects",
				-- 		opts = {
				-- 			textobjects = {
				-- 				select = {
				-- 					enable = true,

				-- 					-- Automatically jump forward to textobj, similar to targets.vim
				-- 					lookahead = true,

				-- 					keymaps = {
				-- 						-- You can use the capture groups defined in textobjects.scm
				-- 						["af"] = "@function.outer",
				-- 						["if"] = "@function.inner",
				-- 						["ac"] = "@class.outer",
				-- 						["ic"] = "@class.inner",
				-- 					},
				-- 					-- You can choose the select mode (default is charwise 'v')
				-- 					selection_modes = {
				-- 						["@parameter.outer"] = "v", -- charwise
				-- 						["@function.outer"] = "V", -- linewise
				-- 						["@class.outer"] = "<c-v>", -- blockwise
				-- 					},
				-- 				},
				-- 			},
				-- 		},
				-- 	},
			},
		},
		opts = {
			ensure_installed = "all",
			sync_install = false,
			ignore_install = { "" }, -- List of parsers to ignore installing
			highlight = {
				enable = true, -- false will disable the whole extension
				disable = { "" }, -- list of language that will be disabled
				additional_vim_regex_highlighting = true,
			},
			indent = {
				enable = false,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					scope_incremental = "<CR>",
					node_incremental = "<TAB>",
					node_decremental = "<S-TAB>",
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
