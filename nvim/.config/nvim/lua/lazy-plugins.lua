require("lazy").setup({
  spec = {
    "tpope/vim-sleuth",
    { 'numToStr/Comment.nvim', opts = {} },

    { import = "plugins" }
  },

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  --
  -- automatically check for plugin updates
  checker = { enabled = true },
})

