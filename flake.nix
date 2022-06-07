{
  description = "NixOps with several plugins installed.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/361bea3f0";

  inputs.poetry2nix = {
    url =
      "github:nix-community/poetry2nix/2d27d4439";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  inputs.flake-utils.url =
    "github:numtide/flake-utils/b543720b2";

  inputs.flake-compat = {
    url =
      "github:edolstra/flake-compat/99f1c2157";
    flake = false;
  };

  outputs = { self, flake-compat, nixpkgs, poetry2nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix.overlay ];
        };
        nixopsPluggable = import ./nixops-pluggable.nix pkgs;

        inherit (nixopsPluggable) overrides nixops;
      in rec {

        defaultApp = {
          type = "app";
          program = "${packages.nixops-plugged}/bin/nixops";
        };

        defaultPackage = packages.nixops-plugged;

        packages = {
          # A nixops with all plugins included.
          nixops-plugged = nixops.withPlugins (ps:
            [
              # ps.nixops-aws
              # ps.nixops-digitalocean
              # ps.nixops-gcp
              # ps.nixops-hetznercloud
              # ps.nixops-virtd
              ps.nixopsvbox
            ]);
          # A nixops with each plugin for users who use a single provider.
          # Benefits from a much faster download/install.
          # nixops-aws = nixops.withPlugins (ps: [ps.nixops-aws]);
          # nixops-gcp = nixops.withPlugins (ps: [ps.nixops-gcp]);
          # nixops-digitalocean = nixops.withPlugins (ps: [ps.nixops-digitalocean]);
          # nixops-hetznercloud = nixops.withPlugins (ps: [ps.nixops-hetznercloud]);
          # nixops-virtd = nixops.withPlugins (ps: [ ps.nixops-virtd ]);
          nixopsvbox = nixops.withPlugins (ps: [ ps.nixopsvbox ]);
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            (pkgs.poetry2nix.mkPoetryEnv {
              inherit overrides;
              projectDir = ./.;
            })
            pkgs.poetry
          ];
        };

      });
}
