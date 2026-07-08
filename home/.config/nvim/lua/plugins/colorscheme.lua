return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000, -- load before all other plugins
    config = function()
      require('rose-pine').setup({
        variant = 'moon', -- matches wezterm's rose-pine-moon
        styles = {
          transparency = true, -- let wezterm's blur/transparency show through
        },
        highlight_groups = {
          -- default is blend 15, which is too faint over the blur
          Visual = { bg = 'iris', blend = 40 },
          -- Give floating windows a solid, raised surface so popups (hover,
          -- docs, completion, pickers) sit clearly on top of the transparent
          -- buffer instead of blending into it. `overlay` is two steps above
          -- the base background, so it reads even over the wezterm blur.
          NormalFloat = { bg = 'overlay' },
          FloatBorder = { fg = 'muted', bg = 'overlay' },
          FloatTitle = { fg = 'foam', bg = 'overlay' },
          Pmenu = { bg = 'overlay' },
          PmenuSel = { bg = 'highlight_high' },
        },
      })

      -- Keep only the true background surfaces transparent (buffer + gutter)
      -- so the wezterm blur shows through the editor. Floats are intentionally
      -- left opaque (see highlight_groups above) to feel layered on top.
      local function make_transparent()
        for _, group in ipairs({
          'Normal',
          'NormalNC',
          'SignColumn',
        }) do
          vim.api.nvim_set_hl(0, group, { bg = 'none' })
        end
      end

      vim.cmd.colorscheme('rose-pine-moon')
      make_transparent()

      -- Re-apply if the colourscheme is ever re-loaded.
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = 'rose-pine*',
        callback = make_transparent,
      })
    end,
  },
}
