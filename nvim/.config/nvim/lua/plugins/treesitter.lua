return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- main branch requires Neovim 0.12+ and tree-sitter-cli
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
    },
    opts = {
      ensure_installed = { 'bash', 'diff', 'html', 'lua', 'markdown' },
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      -- ]f / [f also work as ºf / çf (PT-PT bracket aliases in keymaps.lua)
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { [']f'] = '@function.outer' },
          goto_next_end = { [']F'] = '@function.outer' },
          goto_previous_start = { ['[f'] = '@function.outer' },
          goto_previous_end = { ['[F'] = '@function.outer' },
        },
      },
    },


	-- Remember these keymaps
	-- move = {
	--   enable = true,
	--   set_jumps = true,
	--   goto_next_start = {
	--     [']m'] = '@function.outer',
	--     [']]'] = '@class.outer',
	--   },
	--   goto_next_end = {
	--     [']M'] = '@function.outer',
	--     [']['] = '@class.outer',
	--   },
	--   goto_previous_start = {
	--     ['[m'] = '@function.outer',
	--     ['[['] = '@class.outer',
	--   },
	--   goto_previous_end = {
	--     ['[M'] = '@function.outer',
	--     ['[]'] = '@class.outer',
	--   },
	-- },
	-- swap = {
	--   enable = true,
	--   swap_next = {
	--     ['<leader>a'] = '@parameter.inner',
	--   },
	--   swap_previous = {
	--     ['<leader>A'] = '@parameter.inner',
	--   },
	-- },
}

