return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' }, -- load the LSP stack when opening a real file
    dependencies = {
      {
        'mason-org/mason-lspconfig.nvim',
        opts = {
          -- Servers to auto-install and auto-enable via mason.
          -- rust-analyzer is intentionally omitted: it is handled by
          -- rustaceanvim, which manages its own client (see plugins/rust.lua).
          ensure_installed = {
            'vtsls', -- TypeScript / JavaScript
            'intelephense', -- PHP
            'lua_ls', -- Lua (for editing this config)
          },
          automatic_enable = {
            exclude = { 'rust_analyzer' },
          },
        },
        dependencies = { 'mason-org/mason.nvim' },
      },
    },
    config = function()
      -- Advertise blink.cmp's completion capabilities to every server.
      -- mason-lspconfig enables servers via native vim.lsp.enable(), so we
      -- register the capabilities on the global ('*') LSP config.
      local ok, blink = pcall(require, 'blink.cmp')
      if ok then
        vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() })
      end

      -- Buffer-local keymaps, attached only once an LSP client is present.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
        callback = function(event)
          local map = function(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('K', vim.lsp.buf.hover, 'Hover')
          map('grn', vim.lsp.buf.rename, 'Rename')
          map('gra', vim.lsp.buf.code_action, 'Code Action')
          map('grr', function() Snacks.picker.lsp_references() end, 'References')
          map('gd', function() Snacks.picker.lsp_definitions() end, 'Goto Definition')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('gi', function() Snacks.picker.lsp_implementations() end, 'Goto Implementation')
          map('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'Prev Diagnostic')
          map(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'Next Diagnostic')
        end,
      })
    end,
  },
}
