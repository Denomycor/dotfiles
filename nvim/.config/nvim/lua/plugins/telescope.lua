return {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {

        defaults = {
          file_ignore_patterns = {
            ".uid"
          },
        },

        -- Include symlinks on file search
        pickers = {
          find_files = {
            follow = true
          }
        },

        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },

      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch [T]elescope' })

      vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = '[P]roject [F]iles' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>pt', builtin.live_grep, { desc = '[P]roject [T]okens' })
      vim.keymap.set('n', '<leader>pd', builtin.diagnostics, { desc = '[P]roject [D]iagnostics' })
      vim.keymap.set('n', '<leader>pc', builtin.resume, { desc = '[P]roject [C]ontinue search' })
      vim.keymap.set('n', '<leader>pr', builtin.oldfiles, { desc = '[P]roject [R]ecent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = '[P]roject [B]uffers' })
      vim.keymap.set('n', '<leader>pg', require('telescope.builtin').git_files, { desc = '[P]roject [G]it Files' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>b', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[b] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>po', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[P]roject [O]pen Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

    end
}

