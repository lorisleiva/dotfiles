-- Buffer-local keymaps for Rust, powered by rustaceanvim.
local bufnr = vim.api.nvim_get_current_buf()
local map = function(keys, fn, desc)
  vim.keymap.set('n', keys, fn, { buffer = bufnr, silent = true, desc = 'Rust: ' .. desc })
end

-- Hover actions (run twice, or move into the window, to trigger an action).
map('K', function() vim.cmd.RustLsp({ 'hover', 'actions' }) end, 'Hover Actions')
-- Grouped code actions (nicer than the built-in for rust-analyzer).
map('gra', function() vim.cmd.RustLsp('codeAction') end, 'Code Action')
-- Explain the error under (or after) the cursor.
map('<leader>re', function() vim.cmd.RustLsp('explainError') end, 'Explain Error')
-- Render a diagnostic as cargo would print it.
map('<leader>rd', function() vim.cmd.RustLsp('renderDiagnostic') end, 'Render Diagnostic')
-- Runnables / testables at the cursor.
map('<leader>rr', function() vim.cmd.RustLsp('runnables') end, 'Runnables')
map('<leader>rt', function() vim.cmd.RustLsp('testables') end, 'Testables')
