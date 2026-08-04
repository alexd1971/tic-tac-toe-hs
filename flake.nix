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
          core = haskellPackages.callCabal2nix "tic-tac-toe-core" ./haskell-core { };
          cli = haskellPackages.callCabal2nix "tic-tac-toe-cli" ./haskell-cli {
            "tic-tac-toe-core" = core;
          };
        in
        {
          default = cli;
          tic-tac-toe-core = core;
          tic-tac-toe-cli = cli;
        });

      apps = forEachSystem (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.tic-tac-toe-cli}/bin/tic-tac-toe";
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
              self.packages.${system}.tic-tac-toe-core
              self.packages.${system}.tic-tac-toe-cli
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
