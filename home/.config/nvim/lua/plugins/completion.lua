return {
  {
    'saghen/blink.cmp',
    version = '1.*', -- stable v1 (v2 is under active development)
    event = 'InsertEnter',
    opts = {
      keymap = { preset = 'default' }, -- <C-n>/<C-p> to select, <C-y> to accept
      appearance = { nerd_font_variant = 'mono' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      completion = {
        documentation = { auto_show = true },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
