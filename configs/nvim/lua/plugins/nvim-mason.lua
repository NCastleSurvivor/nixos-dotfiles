return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'williamboman/mason-lspconfig.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('vim-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func)
          vim.keymap.set('n', keys, func, { buffer = event.buf })
        end
        local builtin = require 'telescope.builtin'
        -- 跳转到定义
        map('gd', builtin.lsp_definitions)
        -- 跳转到声明
        map('gD', vim.lsp.buf.declaration)
        -- 查找引用
        map('gr', builtin.lsp_references)
        -- 跳转到实现
        map('gI', builtin.lsp_implementations)
        -- 重命名快捷键
        map('<leader>rn', vim.lsp.buf.rename)
        -- 代码操作快捷键
        map('<leader>ca', vim.lsp.buf.code_action)
        -- 跳转到前一个诊断信息
        map('gk', vim.diagnostic.goto_prev)
        -- 跳转到下一个诊断信息
        map('gj', vim.diagnostic.goto_next)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('vim-lsp-highlight', { clear = true})
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

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('vim-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'vim-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end)
        end
      end
    })
    require("lspconfig").clangd.setup{
      cmd = {
        "/usr/lib/llvm/19/bin/clang",
        -- "--log=verbose",
        -- "--header-insertion=never",
        "--completion-style=detailed",
        "--query-driver=/usr/lib/llvm/19/bin/clang*",
      },
      on_attach = function(client, bufnr)
        if client.server_capabilities.semanticTokensProvider then
          vim.lsp.semantic_tokens.start(bufnr, client.id)
        end
      end,
    }
    require("lspconfig").pyright.setup{
      cmd = {
        "delance-langserver", "--stdio"
      },
      root_dir = function(...)
        return vim.fn.getcwd()
      end,
      on_attach = function(client, bufnr)
        if client.server_capabilities.semanticTokensProvider then
          vim.lsp.semantic_tokens.start(bufnr, client.id)
        end
      end,
    }

    local servers = {
      -- clangd = {
      --   cmd = {
      --     "/home/syh/clang+llvm-18.1.8-aarch64-linux-gnu/bin/clangd",
      --     "--header-insertion=never",
      --     "--query-driver=/opt/homebrew/opt/llvm/bin/clang++",
      --   }
      -- },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            diagnostics = {
              globals = { "vim" }
            },
          },
        },
      },
      --pyright = {
      --  cmd = { "delance-langserver", "--stdio" }, -- pylance
      --  root_dir = function(...)
      --    return vim.fn.getcwd()
      --  end,
      --},
    }

    require('mason').setup()

    -- local ensure_installed = vim.tbl_keys(servers or {})
    local ensure_installed = vim.tbl_keys({})

    vim.list_extend(ensure_installed, {
      'stylua',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }


    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
  }
