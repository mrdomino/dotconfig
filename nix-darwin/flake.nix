{
  description = "Example nix-darwin system flake";

  inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin/master";
  };

  outputs =
    {
      self,
      nix-darwin,
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
            bazel-watcher
            bun
            fd
            ffmpeg
            fswatch
            fzf
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
