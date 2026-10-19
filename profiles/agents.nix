# A dedicated machine for coding agents: only the shared dev tools, no
# personal apps and no GPG key. Commits are signed with the machine's own SSH
# key, so they are verifiable without any personal secret living on it.
#
# After bootstrap, once: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519`, then add
# the public key to GitHub as both an authentication and a signing key.
{ user, ... }:

{
  home-manager.users.${user} = {
    home.sessionVariables.EDITOR = "nvim";

    programs.git.settings = {
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
}
