{
  description = "PCloud nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, home-manager, ... }:
    let
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        nixpkgs.config.allowUnfree = true;
        environment.systemPackages =
          [
            pkgs.neovim
            pkgs.tmux
            pkgs.gh
            pkgs.git
            pkgs.vscode
            pkgs.nixpkgs-fmt
            pkgs.mkalias
            pkgs.jetbrains.clion
            pkgs.jetbrains.idea-ultimate
            pkgs.python313
            pkgs.go
            pkgs.iterm2
            pkgs.nodejs_23
            pkgs.hugo
            pkgs.coreutils
            pkgs.cloc
            pkgs.obsidian
          ];

        fonts.packages = [
          pkgs.fira-code
        ];

        homebrew = {
          enable = true;
          casks = [
            "stats"
            "eloston-chromium"
            "betterdisplay"
            "firefox"
            "orbstack"
          ];
          masApps = {
            "AdGuard for Safari" = 1440147259;
            "Final Cut Pro" = 424389933;
            "WhatsApp" = 310633997;
            "Telegram" = 747648890;
          };
        };

        security.pam.enableSudoTouchIdAuth = true;

        system = {
          keyboard = {
            enableKeyMapping = true;
            remapCapsLockToEscape = true;
          };

          defaults = {
            dock = {
              autohide = true;
              orientation = "left";
              tilesize = 32;
            };
            finder = {
              AppleShowAllExtensions = true;
              ShowPathbar = true;
              ShowStatusBar = true;
            };
            WindowManager = {
              EnableTiledWindowMargins = false;
            };
            NSGlobalDomain = {
              ApplePressAndHoldEnabled = true;
              InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
              KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
            };
          };

          stateVersion = 5;
          configurationRevision = self.rev or self.dirtyRev or null;
          # https://github.com/LnL7/nix-darwin/issues/214
          activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -mindepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';
        };

        nix = {
          settings.experimental-features = "nix-command flakes";
          gc = {
            automatic = true;
          };
        };
        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Junrongs-MacBook-Pro
      darwinConfigurations."Junrongs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "jchen";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = false;
            };
          }
          home-manager.darwinModules.home-manager
          {
            users.users.jchen.home = "/Users/jchen";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.jchen = import ./home.nix;
            };
          }
        ];
      };
    };
}
