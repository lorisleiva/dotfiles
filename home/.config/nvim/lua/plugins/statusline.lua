return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'rose-pine', -- built-in lualine theme matching the colourscheme
        section_separators = '',
        component_separators = '',
        globalstatus = true,
      },
    },
  },
}
