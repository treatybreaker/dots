{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    kanagawa-gtk = {
      url = "path:./pkgs/kanagawa-gtk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bob = {
      url = "path:./pkgs/bob-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    Fmt = {
      url = "path:./pkgs/Fmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar = {
      url = "github:Alexays/Waybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      username = "sam";
    in {
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      targets.genericLinux = { enable = true; };
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs;
            inherit self;
          };
          modules = [
            ({
              imports = [ inputs.agenix.homeManagerModules.default ];
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlay
                inputs.emacs-overlay.overlays.emacs
                inputs.bob.overlays.default
                inputs.Fmt.overlays.default
                inputs.kanagawa-gtk.overlays.default
                inputs.nixgl.overlay
                (final: prev: {
                  waybar = inputs.waybar.packages.${system}.default;
                  lxappearance = prev.lxappearance.overrideAttrs (oldAttrs: {
                    postInstall = ''
                      wrapProgram $out/bin/lxappearance --prefix GDK_BACKEND : x11
                    '';
                  });
                  opensnitch-ui = prev.opensnitch-ui.overrideAttrs (oldAttrs: {
                    propagatedBuildInputs = oldAttrs.propagatedBuildInputs
                      ++ [ prev.python311Packages.qt-material ];
                  });
                })
              ];
              home = {
                username = "${username}";
                homeDirectory = "/home/${username}";
                stateVersion = "24.05";
              };
            })
            ./config
          ];
        };
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.agenix.overlays.default ];
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            age
            age-plugin-yubikey
            pkgs.agenix
            nixos-rebuild
            pkgs.deploy-rs
          ];
          shellHook = ''
            export RULES="$PWD/secrets/secrets.nix"
          '';
        };
      });
}
