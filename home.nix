{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jchen";
  home.homeDirectory = "/Users/jchen";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs = {
    home-manager = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "PCloud";
      userEmail = "heige.pcloud@outlook.com";
      extraConfig = {
        core = {
          editor = "code --wait";
        };
      };
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "shell1" = {
          hostname = "shell1.doc.ic.ac.uk";
          user = "jc4922";
        };

        "shell2" = {
          hostname = "shell2.doc.ic.ac.uk";
          user = "jc4922";
        };

        "shell3" = {
          hostname = "shell3.doc.ic.ac.uk";
          user = "jc4922";
        };

        "shell4" = {
          hostname = "shell4.doc.ic.ac.uk";
          user = "jc4922";
        };

        "shell5" = {
          hostname = "shell5.doc.ic.ac.uk";
          user = "jc4922";
        };
      };
    };
    zsh = {
      enable = true;
      initExtra = ''
        PROMPT='%~ '
      '';
    };
  };
}
