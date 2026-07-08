return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo', 'FormatDisable', 'FormatEnable' },
    keys = {
      {
        '<leader>cf',
        function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
        mode = { 'n', 'v' },
        desc = 'Format Buffer/Selection',
      },
    },
    opts = {
      formatters_by_ft = {
        -- stop_after_first: use the first formatter the project actually has,
        -- so Oxfmt projects use oxfmt and Prettier projects use prettier,
        -- automatically, with no manual switching.
        typescript = { 'oxfmt', 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'oxfmt', 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'oxfmt', 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'oxfmt', 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        rust = { 'rustfmt', lsp_format = 'fallback' },
        php = { 'pint', 'php_cs_fixer', stop_after_first = true },
        lua = { 'stylua' },
      },
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_on_save = function(bufnr)
        -- Respect the disable flags set by the toggle commands below.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,
    },
    init = function()
      -- Let `gq` route through conform.
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Toggle commands for format-on-save (buffer-local with a bang).
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = 'Disable format-on-save (!/buffer)', bang = true })

      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = 'Re-enable format-on-save' })
    end,
  },
}
