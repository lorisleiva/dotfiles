return {
  {
    -- GitHub-style UNIFIED inline diff review: a single buffer showing +/-
    -- lines inline (green added / red removed), as opposed to diffview.nvim's
    -- side-by-side splits. This is now the default review UI, bound to the
    -- <leader>d* keymaps below. diffview.nvim stays installed as a working
    -- fallback (via :DiffviewOpen) and as a neogit dependency.
    --
    -- Driven directly via :CodeDiff; the plugin has no neogit integration.
    -- The C diff engine is a prebuilt binary that auto-downloads on first use.
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    opts = {
      diff = {
        layout = 'inline',  -- unified single-buffer view by default
        compact = true,     -- fold unchanged regions to hunks + context (diffview parity); toggle with `gc`
      },
      explorer = {
        -- <CR> on a file both opens AND focuses the diff (diffview parity).
        focus_on_select = true,
      },
      keymaps = {
        view = {
          -- Cycle files with <Tab>/<S-Tab> (diffview muscle memory). codediff's
          -- native ]f/[f are re-added via the autocmd in `config` below, so both
          -- sets work.
          next_file = '<Tab>',
          prev_file = '<S-Tab>',
        },
      },
    },
    config = function(_, opts)
      require('codediff').setup(opts)
      -- codediff binds next_file/prev_file to a single key each, so remapping
      -- them to <Tab>/<S-Tab> would drop ]f/[f. Re-add ]f/[f tab-locally each
      -- time a review opens so both keymaps navigate files.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeDiffOpen',
        callback = function(ev)
          local nav = require('codediff.ui.view.navigation')
          local tabpage = ev.data and ev.data.tabpage or 0
          if not vim.api.nvim_tabpage_is_valid(tabpage) then return end
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
            local buf = vim.api.nvim_win_get_buf(win)
            vim.keymap.set('n', ']f', nav.next_file, { buffer = buf, desc = 'Next file' })
            vim.keymap.set('n', '[f', nav.prev_file, { buffer = buf, desc = 'Previous file' })
          end
        end,
      })

      -- Work around codediff's explorer-mode compact-default bug: the empty
      -- placeholder diff consumes the plugin's one-shot compact latch
      -- (session.compact_default_applied) before the first real file loads, so
      -- `diff.compact = true` never auto-applies in the explorer flow
      -- (<leader>dd). Rather than enable compact ourselves (which fights the
      -- plugin's per-rebuild refresh and desyncs `gc`), we clear the spent latch
      -- when a file is selected. The plugin's own compact.refresh -- which runs
      -- after every (re)build -- then applies the configured default cleanly and
      -- keeps compact_mode in sync, so `gc` toggles correctly. We only clear the
      -- latch while the user hasn't taken manual control of compact this session.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeDiffFileSelect',
        callback = function(ev)
          local tabpage = ev.data and ev.data.tabpage
          if not tabpage or not vim.api.nvim_tabpage_is_valid(tabpage) then return end
          local lc = require('codediff.ui.lifecycle')
          local s = lc.get_session(tabpage)
          -- Only nudge the very first selection of the session, before the real
          -- diff exists (i.e. while the latch was wrongly spent on the empty
          -- placeholder). Once a real diff has driven compact, leave it alone.
          if s and not s.compact_mode and not s._our_compact_nudged then
            s._our_compact_nudged = true
            s.compact_default_applied = nil  -- let the plugin re-apply the default
          end
        end,
      })
    end,
    keys = {
      { '<leader>dd', '<cmd>CodeDiff<cr>', desc = 'Review uncommitted changes (unified)' },
      { '<leader>dc', function()
          -- Review this branch's changes PR-style: trunk...HEAD via merge-base.
          -- Resolve the trunk from origin/HEAD (main/master/...), default main.
          local ref = vim.fn.systemlist(
            'git symbolic-ref --quiet --short refs/remotes/origin/HEAD')[1]
          local trunk = 'main'
          if vim.v.shell_error == 0 and ref and ref ~= '' then
            trunk = ref:gsub('^origin/', '')
          end
          vim.cmd('CodeDiff ' .. trunk .. '...')
        end, desc = 'Review this branch vs trunk (unified, PR-style)' },
      { '<leader>dh', '<cmd>CodeDiff history %<cr>', desc = 'File history (current file, unified)' },
      { '<leader>dq', function()
          -- Close the review from anywhere in its tab (diffview's DiffviewClose
          -- parity). codediff has no close command; use its public lifecycle API
          -- and no-op when the current tab isn't a review.
          local lc = require('codediff.ui.lifecycle')
          local tab = vim.api.nvim_get_current_tabpage()
          if lc.get_session(tab) then lc.close(tab) end
        end, desc = 'Close review (unified)' },
    },
  },
}
