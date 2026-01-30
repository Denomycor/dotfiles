return {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { "mason-org/mason.nvim", opts = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        }
      }},
      { 'j-hui/fidget.nvim', opts = {} },
      { 'neovim/nvim-lspconfig',
        dependencies = { "saghen/blink.cmp" },
        config = function()

          -- local capabilities = require('blink.cmp').get_lsp_capabilities()
          -- vim.lsp.set_log_level("debug")


          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
            callback = function(event)
              local map = function(keys, func, desc)
                vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
              end

              map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
              map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
              map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
              map('gT', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
              map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
              map('<leader>ps', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[P]roject [S]ymbols')
              map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
              map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
              map('K', vim.lsp.buf.hover, 'Hover Documentation')
              map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
              map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

              -- The following two autocommands are used to highlight references of the
              -- word under your cursor when your cursor rests there for a little while.
              --    See `:help CursorHold` for information about when this is executed
              --
              -- When you move your cursor, the highlights will be cleared (the second autocommand).
              local client = vim.lsp.get_client_by_id(event.data.client_id)
              if client and client.server_capabilities.documentHighlightProvider then
                local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
                vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                  buffer = event.buf,
                  group = highlight_augroup,
                  callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                  buffer = event.buf,
                  group = highlight_augroup,
                  callback = vim.lsp.buf.clear_references,
                })
              end

              -- The following autocommand is used to enable inlay hints in your
              -- code, if the language server you are using supports them
              --
              -- This may be unwanted, since they displace some of your code
              if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                map('<leader>th', function()
                  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                end, '[T]oggle Inlay [H]ints')
              end
            end,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event.buf }
            end,
          })

          -- From here forward we override default lspconfig settings
          vim.lsp.config("lua_ls", {
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" }
                }
              }
            }
          })

          -- vim.lsp.config("godot", {
          --   cmd = vim.lsp.rpc.connect('127.0.0.1', 7011),
          --   filetypes = { "gdscript", "gdshader", "gdshaderinc" },
          --   root_dir = vim.fs.root(0, { "project.godot", ".git" }),
          -- })
          -- vim.lsp.enable("godot")

        end
      },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    opts = {
      automatic_enable = true,
      ensure_installed = { "lua_ls", "clangd", "pyright" },
    }
}

