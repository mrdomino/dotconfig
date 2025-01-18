{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            bazelisk
            bun
            direnv
            fd
            fswatch
            fzf
            git
            git-absorb
            go
            (google-cloud-sdk.withExtraComponents (
              with pkgs.google-cloud-sdk.components;
              [
                app-engine-go
                alpha
                beta
                gke-gcloud-auth-plugin
                kubectl
              ]
            ))
            htop
            jq
            k9s
            lua-language-server
            lua5_1
            luarocks
            mtr
            neovim
            nil
            nixfmt-rfc-style
            nmap
            nodejs
            p7zip
            ripgrep
            tree-sitter
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          programs.zsh.enableGlobalCompInit = false;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };
    };
}
