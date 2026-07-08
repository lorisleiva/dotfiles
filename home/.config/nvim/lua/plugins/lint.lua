return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost', 'InsertLeave' },
    config = function()
      local lint = require('lint')

      lint.linters_by_ft = {
        typescript = { 'oxlint', 'eslint_d' },
        typescriptreact = { 'oxlint', 'eslint_d' },
        javascript = { 'oxlint', 'eslint_d' },
        javascriptreact = { 'oxlint', 'eslint_d' },
        php = { 'phpstan' },
      }

      -- Return only the linters whose resolved executable is available.
      -- oxlint/eslint_d/prettier etc. live in a project's node_modules/.bin
      -- or on PATH; running a missing binary raises a noisy ENOENT, so we
      -- filter them out first (project-local tools only, no globals required).
      local function available_linters(names)
        local out = {}
        for _, name in ipairs(names) do
          local linter = lint.linters[name]
          local cmd = type(linter) == 'table' and linter.cmd or nil
          if type(cmd) == 'function' then
            local ok, resolved = pcall(cmd)
            cmd = ok and resolved or nil
          end
          if cmd and vim.fn.executable(cmd) == 1 then
            out[#out + 1] = name
          end
        end
        return out
      end

      local group = vim.api.nvim_create_augroup('user_nvim_lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
        group = group,
        callback = function()
          -- Only lint modifiable, real-file buffers.
          if not (vim.bo.modifiable and vim.bo.buftype == '') then
            return
          end
          local names = lint.linters_by_ft[vim.bo.filetype] or {}
          local runnable = available_linters(names)
          if #runnable > 0 then
            lint.try_lint(runnable, { ignore_errors = true })
          end
        end,
      })
    end,
  },
}
