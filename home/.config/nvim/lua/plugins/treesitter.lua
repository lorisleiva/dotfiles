return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- built for Neovim 0.12+; fixes the markdown-injection hover crash
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')

      -- Install the parsers we use (async; a no-op if already installed).
      ts.install({
        'typescript',
        'tsx',
        'javascript',
        'rust',
        'php',
        'lua',
        'json',
        'markdown',
        'markdown_inline',
        'bash',
        'vimdoc',
      })

      -- On the main branch, highlighting and indentation are enabled per-buffer
      -- rather than globally. Turn them on for the filetypes we care about.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
        pattern = {
          'typescript',
          'typescriptreact',
          'javascript',
          'javascriptreact',
          'rust',
          'php',
          'lua',
          'json',
          'markdown',
          'sh',
          'bash',
        },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
