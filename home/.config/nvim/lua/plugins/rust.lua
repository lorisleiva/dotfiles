return {
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false, -- the plugin implements its own lazy-loading
    init = function()
      -- Many projects pin a toolchain via rust-toolchain.toml (e.g. Solana
      -- programs pin 1.93.0). Those toolchains often lack the rust-analyzer
      -- component, so the default `rust-analyzer` shim quits with a non-zero
      -- exit code. Pin the server to a single toolchain that always has RA
      -- installed (`rustup component add rust-analyzer --toolchain stable`).
      -- rust-analyzer is version-tolerant, so one RA works across projects.
      vim.g.rustaceanvim = {
        server = {
          cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
        },
      }
    end,
  },
}
