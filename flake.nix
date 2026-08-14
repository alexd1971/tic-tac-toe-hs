{
  description = "Haskell tic-tac-toe core, CLI, and Flutter integration example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          haskellPackages = pkgs.haskell.packages.ghc9103;
          buildFlutterApplication =
            pkgs.callPackage
              (nixpkgs + /pkgs/development/compilers/flutter/build-support/build-flutter-application.nix)
              { };
          core = haskellPackages.callPackage ./haskell-core/nix/generated/tic-tac-toe-core.nix { };
          cli = haskellPackages.callPackage ./haskell-cli/nix/generated/tic-tac-toe-cli.nix {
            "tic-tac-toe-core" = core;
          };
          server = haskellPackages.callPackage ./haskell-server/nix/generated/tic-tac-toe-server.nix {
            "tic-tac-toe-core" = core;
          };
          web = buildFlutterApplication {
            pname = "tic-tac-toe-web";
            version = "0.1.0";
            src = ./flutter-gui;
            sourceRoot = "flutter-gui/flutter-app";
            packageRoot = "flutter-app";
            autoPubspecLock = ./flutter-gui/flutter-app/pubspec.lock;
            targetFlutterPlatform = "web";
          };
          webStatic = pkgs.runCommand "tic-tac-toe-web-static" { } ''
            mkdir -p "$out/app/static"
            cp -R "${web}/." "$out/app/static/"
            chmod -R u+w "$out/app/static"
            find "$out/app/static" -type f -name '*.symbols' -delete
          '';
          ociRoot = pkgs.buildEnv {
            name = "tic-tac-toe-web-root";
            paths = [
              server
              webStatic
            ];
            pathsToLink = [
              "/app"
              "/bin"
            ];
          };
        in
        {
          default = cli;
          core = core;
          cli = cli;
          server = server;
          web = web;
        } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          web-app-image = pkgs.dockerTools.buildLayeredImage {
            name = "tic-tac-toe-hs";
            tag = "latest";
            contents = [ ociRoot ];
            config = {
              Cmd = [ "/bin/tic-tac-toe-server" ];
              Env = [
                "PORT=8081"
                "STATIC_DIR=/app/static"
              ];
              ExposedPorts = {
                "8081/tcp" = { };
              };
            };
          };
        });

      apps = forEachSystem (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.cli}/bin/tic-tac-toe";
          meta.description = "Run the native tic-tac-toe CLI";
        };
        server = {
          type = "app";
          program = "${self.packages.${system}.server}/bin/tic-tac-toe-server";
          meta.description = "Run the tic-tac-toe HTTP API server";
        };
      });

      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          haskellPackages = pkgs.haskell.packages.ghc9103;
        in
        {
          default = haskellPackages.shellFor {
            packages = _: [
              self.packages.${system}.core
              self.packages.${system}.cli
              self.packages.${system}.server
            ];
            buildInputs = [
              haskellPackages.cabal-install
              haskellPackages.ghc
              haskellPackages.haskell-language-server
            ];
          };
        });
    };
}
