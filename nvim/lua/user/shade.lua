local wk = require('which-key')

require'shade'.setup({
  overlay_opacity = 50,
  opacity_step = 1,
})

wk.register({
  ["<leader>"] = {
    s = { "<cmd>lua require('shade').toggle()<cr>", "shade toggle", noremap=true, silent=true },
  }
})

