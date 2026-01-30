return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- main branch is not working 
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    dependencies = { 'nvim-treesitter/nvim-treesitter-context' },
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

