{
  description = "Flutter integration for the Haskell tic-tac-toe core";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    th-cross.url = "path:/home/alexey/Projects/flutter-bridges/th-cross";
    th-cross.inputs.nixpkgs.follows = "nixpkgs";
    haskell-ffi-th.url = "path:/home/alexey/Projects/flutter-bridges/haskell-ffi-th";
    haskell-ffi-th.inputs.nixpkgs.follows = "nixpkgs";
    flutter-haskell-bridge.url = "path:/home/alexey/Projects/flutter-bridges/flutter-haskell-bridge";
    flutter-haskell-bridge.inputs.nixpkgs.follows = "nixpkgs";
    flutter-haskell-bridge.inputs.th-cross.follows = "th-cross";
  };

  outputs = { self, nixpkgs, th-cross, haskell-ffi-th, flutter-haskell-bridge, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;

      ghcVersion = "9.10.3";
      target = "aarch64-android";
      androidAbi = "arm64-v8a";

      importNixpkgs = system:
        import nixpkgs {
          inherit system;
          # Android SDK/NDK derivations include unfree archives.
          config.allowUnfree = true;
        };
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = importNixpkgs system;
          packageFile = ./haskell-ffi/nix/generated/tic-tac-toe-ffi.nix;
          tools = import (flutter-haskell-bridge + /nix/tools.nix) { inherit pkgs; };
          bridge = import (flutter-haskell-bridge + /nix/bridge-lib.nix) {
            inherit pkgs th-cross system;
          };
        in
        {
          android-jni-libs =
            bridge.buildHaskellLib {
              inherit ghcVersion target androidAbi packageFile;
              name = "tic_tac_toe";
              manifestFile = "ffi-manifest.json";
              localPackages = {
                haskell-ffi-th = {
                  packageFile = haskell-ffi-th + /nix/generated/haskell-ffi-th.nix;
                };
                tic-tac-toe-core = {
                  packageFile = ../haskell-core/nix/generated/tic-tac-toe-core.nix;
                };
              };
            };

          dart-api =
            pkgs.runCommand "tic-tac-toe-dart-api" { } ''
              mkdir -p "$out"
              ${tools.dartFfiGenerator}/bin/flutter-haskell-generate-dart-ffi \
                --spec ${self.packages.${system}.android-jni-libs}/ffi-manifest.json \
                --out "$out/tic_tac_toe_api.dart"
            '';

          default = self.packages.${system}.android-jni-libs;
        });

      apps = forEachSystem (system:
        let
          pkgs = importNixpkgs system;
          regenScript =
            pkgs.writeShellScriptBin "regen-haskell-nix" ''
              set -euo pipefail

              regenerate() {
                local package_dir="$1"
                local output_file="$2"
                mkdir -p "$package_dir/nix/generated"
                (
                  cd "$package_dir/nix/generated"
                  ${pkgs.cabal2nix}/bin/cabal2nix ../.. > "$output_file"
                )
              }

              regenerate ../haskell-core tic-tac-toe-core.nix
              regenerate haskell-ffi tic-tac-toe-ffi.nix
            '';
          syncScript =
            pkgs.writeShellScriptBin "sync-haskell-artifacts" ''
              set -euo pipefail

              ${regenScript}/bin/regen-haskell-nix

              jni_libs="$(nix build --no-link --print-out-paths .#android-jni-libs)"
              dart_api="$(nix build --no-link --print-out-paths .#dart-api)"

              target_dir="bridge/android/src/main/jniLibs/${androidAbi}"
              if [ -e "$target_dir" ]; then
                chmod -R u+w "$target_dir"
                rm -rf "$target_dir"
              fi
              mkdir -p "$(dirname "$target_dir")"
              cp -R "$jni_libs/${androidAbi}" "$target_dir"
              chmod -R u+w "$target_dir"

              cp "$dart_api/tic_tac_toe_api.dart" bridge/lib/tic_tac_toe_api.dart
            '';
        in
        {
          regen-haskell-nix = {
            type = "app";
            program = "${regenScript}/bin/regen-haskell-nix";
            meta.description = "Regenerate cabal2nix files for the Haskell packages";
          };

          sync-haskell-artifacts = {
            type = "app";
            program = "${syncScript}/bin/sync-haskell-artifacts";
            meta.description = "Build and copy Haskell JNI libraries and generated Dart API";
          };
        });

      devShells = forEachSystem (system:
        let
          pkgs = importNixpkgs system;
          tools = import (flutter-haskell-bridge + /nix/tools.nix) { inherit pkgs; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.android-tools
              pkgs.cabal-install
              pkgs.cabal2nix
              pkgs.jdk17
              tools.dartFfiGenerator
            ];

            shellHook = ''
              cat <<'EOF'
Tic-tac-toe Flutter/Haskell shell

Common commands:
  nix run .#regen-haskell-nix
  nix run .#sync-haskell-artifacts

Android SDK/device configuration is still owned by Flutter/Android tooling.
EOF
            '';
          };
        });
    };
}
