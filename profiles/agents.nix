# A dedicated machine for coding agents: only the shared dev tools, no
# personal apps and no GPG key. Commits are signed with the machine's own SSH
# key, so they are verifiable without any personal secret living on it.
#
# After bootstrap, once: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519`, then add
# the public key to GitHub as a signing key only (an authentication key would
# reach every repository of the account; git uses HTTPS with a narrow token).
{ user, ... }:

{
  # Tailscale as the open-source system daemon (`tailscaled`), not the app: it
  # runs at boot, before anyone logs in, so after a restart the machine is back
  # on the tailnet and its login window is reachable over Screen Sharing (the
  # app only connects once a user is logged in, and with FileVault on there is
  # no automatic login). Join once with `sudo tailscale up --auth-key=…`.
  services.tailscale.enable = true;

  home-manager.users.${user} =
    { config, ... }:
    let
      home = config.home.homeDirectory;
    in
    {
      home.sessionVariables.EDITOR = "nvim";

      # A headless OpenCode server other machines attach their TUI to through an
      # SSH tunnel (`oc-remote` in the personal profile). It listens on loopback
      # only, behind a password kept outside this repo:
      #   openssl rand -base64 24 > ~/.config/opencode/server-password
      #   chmod 600 ~/.config/opencode/server-password
      # It is a user agent, so it runs once the account is logged in, which is
      # also what unlocks the keychain the Anthropic plugins read their logins
      # from. The shell is interactive and login (`-il`, as Paseo starts agents)
      # so the agent's commands see the same PATH as a terminal; its plugins
      # print harmless "can't change option: zle" lines to the log without a tty.
      launchd.agents.opencode-serve = {
        enable = true;
        config = {
          ProgramArguments = [
            "/bin/zsh"
            "-ilc"
            ''export OPENCODE_SERVER_PASSWORD="$(cat ~/.config/opencode/server-password)" && exec opencode serve --hostname 127.0.0.1 --port 4096''
          ];
          WorkingDirectory = "${home}/Code";
          RunAtLoad = true;
          KeepAlive = true;
          ThrottleInterval = 30;
          StandardOutPath = "${home}/Library/Logs/opencode-serve.log";
          StandardErrorPath = "${home}/Library/Logs/opencode-serve.log";
        };
      };

      programs.git.settings = {
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519.pub";
      };
    };
}
