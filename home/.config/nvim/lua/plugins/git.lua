return {
  {
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    keys = { { '<leader>g', function() require('neogit').open() end, desc = 'Neogit' } },
  },
  {
    -- Side-by-side review UI. Two flows (see keymaps):
    --   <leader>dd  review uncommitted changes (AI output / pre-commit work)
    --   <leader>dc  review a single commit (a Graphite branch's PR)
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    -- opts is a function so it runs at load time (diffview on rtp), letting us
    -- require('diffview.actions') for the focus_entry keymap.
    opts = function()
      local actions = require('diffview.actions')
      return {
        use_icons = true,          -- via nvim-web-devicons
        enhanced_diff_hl = true,   -- clearer intra-line highlights
        -- --imply-local puts the live on-disk file on the right side, so LSP,
        -- diagnostics and treesitter work while reviewing -> fix mistakes in place.
        default_args = { DiffviewOpen = { '--imply-local' } },
        view = { default = { layout = 'diff2_horizontal' } },
        keymaps = {
          file_panel = {
            -- <CR> opens the diff AND drops the cursor into the current-state
            -- (right) window, so review is: pick file -> <CR> -> scroll. Move
            -- between files with <Tab>/<S-Tab> from the diff; <leader>e returns
            -- to the panel. (o/l keep the default show-without-focus behaviour.)
            { 'n', '<cr>', actions.focus_entry, { desc = 'Open diff and focus it' } },
            -- Stage hunks with `-`/`s` (defaults), then commit here via Neogit.
            { 'n', 'cc', function() require('neogit').open({ 'commit' }) end, { desc = 'Commit staged changes' } },
          },
          file_history_panel = {
            { 'n', '<cr>', actions.focus_entry, { desc = 'Open diff and focus it' } },
          },
        },
      }
    end,
    keys = {
      { '<leader>dd', '<cmd>DiffviewOpen<cr>', desc = 'Review uncommitted changes' },
      { '<leader>dc', function()
          -- Review the commit under the cursor (works from Neogit/log), else
          -- fall back to browsing this branch's commit history.
          local sha = vim.fn.expand('<cword>')
          if sha:match('^%x%x%x%x%x%x%x+$') then
            vim.cmd('DiffviewOpen ' .. sha .. '^!')
          else
            vim.cmd('DiffviewFileHistory')
          end
        end, desc = 'Review a commit' },
      { '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history (current file)' },
      { '<leader>dq', '<cmd>DiffviewClose<cr>', desc = 'Close review' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufWinEnter',
    opts = {
      current_line_blame = true,  -- who last touched this line
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- Inline stage/preview without opening diffview.
        map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
      end,
    },
  },
}
