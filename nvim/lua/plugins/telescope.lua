return {
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").setup({})
    end,
  },
	{
		"natecraddock/telescope-zf-native.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
    config = function()
      require("telescope").load_extension("zf-native")
    end,
	},
	{
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
    config = function()
      require("telescope").load_extension("harpoon")
    end,
	},
}
