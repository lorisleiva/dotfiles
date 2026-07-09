# herdr-plus project + worktree templates, generated from a single source of truth.
#
# Why a generator instead of `home.file`?
#   ~/.config/herdr is an out-of-store symlink into this repo, so the whole herdr
#   config tree is live-edited in-repo. home-manager cannot manage files *beneath*
#   an out-of-store symlink, so we render the templates with an activation script
#   that writes into the repo-backed config dir after linking. Files are committed.
#
# Design:
#   The layout SHAPE is a per-repo property, defined once here and rendered into
#   BOTH projects/<file>.toml and worktrees/<file>.toml so they can never diverge.
#   Change `defaultTabs` -> every repo's project AND worktree layout regenerates.
#   A repo needing a bespoke shape sets its own `tabs`, applied to both outputs.
{ config, lib, pkgs, ... }:

let
  # Where herdr-plus reads its config (per `herdr plugin config-dir`).
  # This lives inside the out-of-store-symlinked ~/.config/herdr tree, i.e. the repo.
  pluginConfigDir = "${config.home.homeDirectory}/.config/herdr/plugins/config/cloudmanic.herdr-plus";

  # ---------------------------------------------------------------------------
  # Default layout shape: three "windows" (tabs).
  #   - "ai":     opencode + a clean terminal side by side (panes)
  #   - "code":   nvim
  #   - "review": nvim with the diffview review already open (see nvim git.lua)
  # Tweak here to change the shape for every repo that doesn't override it.
  # (herdr-plus caps a tab at 4 panes.)
  # ---------------------------------------------------------------------------
  defaultTabs = [
    {
      name = "ai";
      panes = [
        { label = "opencode"; command = "opencode"; }
        { label = "terminal"; split = "right"; }
      ];
    }
    {
      name = "code";
      command = "nvim ."; # open the file tree at the project's working_dir (repo root)
    }
    {
      name = "review";
      # nvim with the review (DiffviewOpen, i.e. <leader>dd) already up. Uses -c
      # rather than sending keystrokes so it's independent of keymap load timing;
      # --imply-local still applies via default_args in the nvim diffview config.
      command = "nvim -c DiffviewOpen";
    }
  ];

  # ---------------------------------------------------------------------------
  # Group -> directory root. A repo's working dir is "<root>/<repo>".
  # ---------------------------------------------------------------------------
  groups = {
    "solana-program" = "~/Code/@solana-program";
    "codama" = "~/Code/@codama";
    "solana" = "~/Code/@solana";
    "personal" = "~/Code";
  };

  # ---------------------------------------------------------------------------
  # Repo entries. Each is { group, repo } and inherits `defaultTabs`.
  # Optional per-entry overrides:
  #   name      - display/name + filename stem (defaults to repo)
  #   dir       - explicit working_dir (defaults to "<group root>/<repo>")
  #   tabs      - bespoke layout shape (defaults to defaultTabs)
  #   worktree  - false to suppress the worktrees/ file (e.g. non-git-repo dirs)
  # ---------------------------------------------------------------------------
  repos = [
    # -- solana-program (23) --
    { group = "solana-program"; repo = "account-compression"; }
    { group = "solana-program"; repo = "actions"; }
    { group = "solana-program"; repo = "address-lookup-table"; }
    { group = "solana-program"; repo = "associated-token-account"; }
    { group = "solana-program"; repo = "compute-budget"; }
    { group = "solana-program"; repo = "config"; }
    { group = "solana-program"; repo = "create-solana-program"; }
    { group = "solana-program"; repo = "loader-v3"; }
    { group = "solana-program"; repo = "loader-v4"; }
    { group = "solana-program"; repo = "memo"; }
    { group = "solana-program"; repo = "program-metadata"; }
    { group = "solana-program"; repo = "record"; }
    { group = "solana-program"; repo = "secp256k1"; }
    { group = "solana-program"; repo = "single-pool"; }
    { group = "solana-program"; repo = "stake"; }
    { group = "solana-program"; repo = "stake-pool"; }
    { group = "solana-program"; repo = "system"; }
    { group = "solana-program"; repo = "token"; }
    { group = "solana-program"; repo = "token-2022"; }
    { group = "solana-program"; repo = "token-group"; }
    { group = "solana-program"; repo = "token-metadata"; }
    { group = "solana-program"; repo = "token-wrap"; }
    { group = "solana-program"; repo = "vote"; }

    # -- codama (9) --
    { group = "codama"; repo = "codama"; }
    { group = "codama"; repo = "codama-rs"; }
    { group = "codama"; repo = "renderers-demo"; }
    { group = "codama"; repo = "renderers-js"; }
    { group = "codama"; repo = "renderers-js-umi"; }
    { group = "codama"; repo = "renderers-rust"; }
    { group = "codama"; repo = "renderers-rust-cpi"; }
    { group = "codama"; repo = "renderers-vixen-parser"; }
    { group = "codama"; repo = "spec"; }
    # whole-folder view for full-context AI sessions. Not a git repo -> project only.
    {
      group = "codama";
      repo = "codama-all";
      name = "codama (all)";
      dir = "~/Code/@codama";
      worktree = false;
    }

    # -- solana (3) --
    { group = "solana"; repo = "kit"; }
    { group = "solana"; repo = "kit-plugins"; }
    { group = "solana"; repo = "js-configs"; }

    # -- personal (4) --
    { group = "personal"; repo = "cortex"; }
    { group = "personal"; repo = "dotfiles"; }
    { group = "personal"; repo = "laravel-actions"; }
    { group = "personal"; repo = "lody"; }
  ];

  # ---------------------------------------------------------------------------
  # TOML rendering. herdr-plus's TOML is simple (strings + arrays of tables),
  # so we render by hand to keep exact control over [[tabs]] / [[tabs.panes]].
  # ---------------------------------------------------------------------------
  q = s: "\"" + (lib.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] s) + "\"";

  # Render one pane inside a [[tabs.panes]] block.
  renderPane = tabName: pane:
    let
      lines =
        (lib.optional (pane ? label && pane.label != "") "label = ${q pane.label}")
        ++ (lib.optional (pane ? command && pane.command != "") "command = ${q pane.command}")
        ++ (lib.optional (pane ? split && pane.split != "") "split = ${q pane.split}");
    in
    "\n[[tabs.panes]]\n" + (lib.concatStringsSep "\n" lines) + "\n";

  # Render one [[tabs]] block: either a single `command` or nested panes.
  renderTab = tab:
    let
      header = "\n[[tabs]]\nname = ${q tab.name}\n";
      body =
        if (tab ? panes && tab.panes != [ ])
        then lib.concatStrings (map (renderPane tab.name) tab.panes)
        else if (tab ? command && tab.command != "")
        then "command = ${q tab.command}\n"
        else ""; # empty shell
    in
    header + body;

  tabsToml = tabs: lib.concatStrings (map renderTab tabs);

  # Resolve an entry's effective fields.
  resolve = e: rec {
    stem = "${e.group}-${e.repo}"; # group-prefixed filename to avoid collisions
    name = e.name or e.repo;
    tabs = e.tabs or defaultTabs;
    workingDir = e.dir or "${groups.${e.group}}/${e.repo}";
    wantWorktree = e.worktree or true;
    matchRepo = e.repo; # worktree matcher = real repo basename (NOT the stem)
  };

  # projects/<stem>.toml
  projectFile = e:
    let r = resolve e; in
    {
      name = "projects/${r.stem}.toml";
      text = ''
        # GENERATED by herdr-plus.nix — do not edit by hand.
        # Change the shape or repo list in herdr-plus.nix and rebuild.
        name = ${q r.name}
        group = ${q e.group}
        working_dir = ${q r.workingDir}
      '' + (tabsToml r.tabs);
    };

  # worktrees/<stem>.toml (skipped when worktree = false)
  worktreeFile = e:
    let r = resolve e; in
    {
      name = "worktrees/${r.stem}.toml";
      text = ''
        # GENERATED by herdr-plus.nix — do not edit by hand.
        # Change the shape or repo list in herdr-plus.nix and rebuild.
        repo = ${q r.matchRepo}
      '' + (tabsToml r.tabs);
    };

  projectFiles = map projectFile repos;
  worktreeFiles = map worktreeFile (lib.filter (e: (e.worktree or true)) repos);

  # Wildcard worktree fallback for repos not declared above.
  wildcardWorktree = {
    name = "worktrees/wildcard.toml";
    text = ''
      # GENERATED by herdr-plus.nix — do not edit by hand.
      # Fallback layout for any worktree whose repo isn't declared in herdr-plus.nix.
      repo = "*"
    '' + (tabsToml defaultTabs);
  };

  allFiles = projectFiles ++ worktreeFiles ++ [ wildcardWorktree ];

  # Emit each file as a write command in the activation script.
  writeCmd = f: ''
    $DRY_RUN_CMD install -m 0644 ${pkgs.writeText "herdr-plus-file" f.text} \
      "${pluginConfigDir}/${f.name}"
  '';
in
{
  # Install the plugin when its registry entry is missing. herdr clones + builds a
  # per-machine binary (not covered by committing ~/.config/herdr), so a fresh
  # machine needs this to make the plugin usable. Idempotent: skips when present.
  # herdr is a Homebrew formula, so we look for it on the standard brew path.
  home.activation.herdrPlusInstall = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    herdrBin="/opt/homebrew/bin/herdr"
    registry="${config.home.homeDirectory}/.config/herdr/plugins.json"
    if [ -x "$herdrBin" ]; then
      if ! ( [ -f "$registry" ] && grep -q '"cloudmanic.herdr-plus"' "$registry" ); then
        $DRY_RUN_CMD "$herdrBin" plugin install cloudmanic/herdr-plus --yes || \
          echo "herdr-plus: plugin install failed (non-fatal); run it manually." >&2
      fi
    else
      echo "herdr-plus: herdr not found at $herdrBin; skipping plugin install." >&2
    fi
  '';

  # Regenerate templates on every activation. We wipe the two generated dirs first
  # so removing a repo from the list also removes its stale files, then write fresh.
  # Runs after install so the canonical config dir exists (we mkdir it too, to be safe).
  home.activation.herdrPlusTemplates = lib.hm.dag.entryAfter [ "herdrPlusInstall" ] ''
    $DRY_RUN_CMD mkdir -p "${pluginConfigDir}/projects" "${pluginConfigDir}/worktrees"
    $DRY_RUN_CMD rm -f "${pluginConfigDir}/projects/"*.toml "${pluginConfigDir}/worktrees/"*.toml
    ${lib.concatStrings (map writeCmd allFiles)}
  '';
}
