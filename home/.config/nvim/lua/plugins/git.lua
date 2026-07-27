return {
  {
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    keys = { { '<leader>g', function() require('neogit').open() end, desc = 'Neogit' } },
  },
  {
    -- Side-by-side review UI, kept as a fallback and as a neogit dependency.
    -- The <leader>d* review keymaps now drive codediff's unified inline view
    -- (see plugins/codediff.lua); diffview remains reachable via :DiffviewOpen.
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    -- opts is a function so it runs at load time (diffview on rtp), letting us
    -- require('diffview.actions') for the focus_entry keymap.
    opts = function()
      local actions = require('diffview.actions')
      -- Robust refresh: diffview attaches its `R` keymap to the non-modifiable
      -- `diffview://null` placeholder shown when a diff is empty. Refreshing from
      -- there runs update_files -> set_file against the current (null) window and
      -- fails with `E21: 'modifiable' is off`. Focusing the file list first moves
      -- off the null buffer, then we refresh via the public tabpage-scoped API.
      local function robust_refresh()
        local view = require('diffview.lib').get_current_view()
        if not view then return end
        actions.focus_files()   -- leave diffview://null, land on the file list (position preserved)
        view:update_files()     -- refresh via the public, tabpage-scoped API
      end
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
            { 'n', 'R', robust_refresh, { desc = 'Refresh (focus list first, fixes E21 on empty diff)' } },
          },
          view = {
            -- Override diffview's default `R` on diff/null buffers (see robust_refresh).
            { 'n', 'R', robust_refresh, { desc = 'Refresh (focus list first, fixes E21 on empty diff)' } },
          },
          file_history_panel = {
            { 'n', '<cr>', actions.focus_entry, { desc = 'Open diff and focus it' } },
          },
        },
      }
    end,
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
