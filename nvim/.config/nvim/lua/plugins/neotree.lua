return {
	"nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
  -- Loaded at startup so hijack_netrw_behavior can open `nvim <dir>`
  lazy = false,

	init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,

	keys = {
		{ "<leader>tt", "<cmd>Neotree left filesystem toggle<CR>", desc = "NeoTree toggle" },
    { "<leader>tb", "<cmd>Neotree left buffers toggle<CR>", desc = "NeoTree buffers" },
		{ "<leader>tf", "<cmd>Neotree float buffers toggle<CR>", desc = "NeoTree float" },
		{ "<leader>tl", "<cmd>Neotree left<CR>", desc = "NeoTree left" },
	},

  opts = {
    popup_border_style = "",
    -- enable_git_status = false,
    enable_diagnostics = false,
    filesystem = {
      filtered_items = {
        hide_by_pattern = { "*.uid" },
      },
      hijack_netrw_behavior = "open_current",
      window = {
        width = 30,
        mappings = {
          ["\\"] = "close_window",
          ["f"] = "",
        },
      },
    },
    default_component_configs = {
      last_modified = {
        format = "%d-%m-%y %H:%M",
      },
      created = {
        format = "%d-%m-%y %H:%M",
      },
      git_status = {
        symbols = {
          added     = "+",
          modified  = "~",
          deleted   = "-",
          renamed   = "→",
          untracked = "?",
          ignored   = ".",
          unstaged  = "x",
          staged    = "✓",
          conflict  = "!",
        },
      },
    },
  },

}

-- vim: ts=2 sts=2 sw=2 et
