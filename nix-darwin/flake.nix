{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
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
            age
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
              with google-cloud-sdk.components;
              [
                app-engine-go
                alpha
                beta
                gke-gcloud-auth-plugin
                kubectl
              ]
            ))
            graphviz
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
            pass
            passage
            ripgrep
            stylua
            tree-sitter
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          programs = {
            zsh = {
              enable = true;
              enableGlobalCompInit = false;
            };
          };

          system = {
            configurationRevision = self.rev or self.dirtyRev or null;
            # Used for backwards compatibility, please read the changelog
            # before changing.
            # $ darwin-rebuild changelog
            stateVersion = 5;
          };

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
