-- Keymap for sending a comment to the workspace's AI agent (opencode, claude,
-- codex, ...). Works in any file buffer in the workspace (review pane, code
-- pane, etc.). Logic lives in lua/review.lua.
--   ga (normal)  -> comment on the current line
--   ga (visual)  -> comment on the selected range
-- Overrides the rarely-used builtin `ga` (print char codepoint).
return {
  {
    name = 'review-comments',
    dir = vim.fn.stdpath('config'), -- local, nothing to fetch
    lazy = false,
    keys = {
      {
        'ga',
        function() require('review').comment(nil) end,
        mode = 'n',
        desc = 'Comment to agent (current line)',
      },
      {
        'ga',
        function()
          -- Capture the selection's line range, then leave visual mode
          -- synchronously (mode 'x') so the box's startinsert isn't undone by a
          -- late-queued <Esc>.
          local a = vim.fn.line('v')
          local b = vim.fn.line('.')
          if a > b then a, b = b, a end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'nx', false)
          require('review').comment({ a, b })
        end,
        mode = 'x',
        desc = 'Comment to agent (selection)',
      },
    },
  },
}
