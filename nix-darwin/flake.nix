{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            age
            bazelisk
            bazel-watcher
            bun
            fd
            ffmpeg
            fswatch
            fzf
            gh
            git
            git-absorb
            gnumake
            gnupg
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
            helix
            htop
            jq
            k9s
            lua-language-server
            lua5_1
            luarocks
            mtr
            neovim
            nixd
            nixfmt-rfc-style
            nmap
            nodejs
            par
            p7zip
            pass
            passage
            ripgrep
            stylua
            texlive.combined.scheme-medium
            tmux
            tree-sitter
            watchman
          ];

          nix.enable = false;

          programs = {
            direnv = {
              enable = true;
              nix-direnv = {
                enable = true;
                package = pkgs.nix-direnv;
              };
            };
            zsh = {
              enable = true;
              enableGlobalCompInit = false;
            };
          };

          security.pam.services.sudo_local = {
            enable = true;
            touchIdAuth = true;
            watchIdAuth = false;
          };

          system = {
            configurationRevision = self.rev or self.dirtyRev or null;

            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 6;
          };

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
