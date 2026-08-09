{
  description = "Flutter integration for the Haskell tic-tac-toe core";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    th-cross.url = "github:alexd1971/template-haskell-cross";
    th-cross.inputs.nixpkgs.follows = "nixpkgs";
    haskell-ffi-th.url = "github:alexd1971/haskell-ffi-th";
    haskell-ffi-th.inputs.nixpkgs.follows = "nixpkgs";
    flutter-haskell-bridge.url = "github:alexd1971/flutter-haskell-bridge";
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
          config = {
            # Android SDK/NDK derivations include unfree archives.
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      artifactOutputsFor = system:
        let
          pkgs = importNixpkgs system;
          haskellPackages = import ./haskell-packages.nix;
          bridge = import (flutter-haskell-bridge + /nix/bridge-lib.nix) {
            inherit pkgs th-cross system;
          };
          tools = import (flutter-haskell-bridge + /nix/tools.nix) { inherit pkgs; };
        in
        import (flutter-haskell-bridge + /nix/flutter-artifacts.nix) {
          inherit pkgs ghcVersion androidAbi;
          inherit (haskellPackages) localHaskellPackages regeneratePackages;
          haskellFfiTh = haskell-ffi-th;
          bridgeLib = bridge;
          dartFfiGenerator = tools.dartFfiGenerator;
          androidTarget = target;
          ffiLibraryName = "tic_tac_toe";
          flutterPackageDir = "flutter-haskell-bridge";
          nativeLinkMode = "static-haskell";
          packageFile = ./haskell-ffi/nix/generated/tic-tac-toe-ffi.nix;
          dartApiFile = "tic_tac_toe_api.dart";
        };
    in
    {
      packages = forEachSystem (system: (artifactOutputsFor system).packages);

      apps = forEachSystem (system: (artifactOutputsFor system).apps);

      devShells = forEachSystem (system:
        let
          pkgs = importNixpkgs system;
          tools = flutter-haskell-bridge.lib.${system}.tools;
          flutterSdk = tools.flutterSdk;
          androidSdk = tools.androidSdk;
        in
        {
          default = pkgs.mkShell {
            packages = [
              flutterSdk.flutter
              flutterSdk.flutterSdkPath
              pkgs.cabal-install
              pkgs.cabal2nix
              pkgs.jdk17
              tools.dartFfiGenerator
            ];

            shellHook = ''
              # Materialise the writable Flutter SDK farm.
              flutter_sdk_path="$(${flutterSdk.flutterSdkPath}/bin/flutter-sdk-path)"

              export ANDROID_HOME="${androidSdk.sdkRoot}"
              export ANDROID_SDK_ROOT="${androidSdk.sdkRoot}"

              if [ -d flutter-app/android ]; then
                local_properties=flutter-app/android/local.properties
              elif [ -d android ]; then
                local_properties=android/local.properties
              else
                local_properties=
              fi

              if [ -n "$local_properties" ]; then
                cat > "$local_properties" <<EOF
sdk.dir=${androidSdk.sdkRoot}
flutter.sdk=$flutter_sdk_path
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
EOF
              fi

              cat <<EOF
Tic-tac-toe Flutter/Haskell shell

Common commands:
  nix run .#regen-haskell-nix
  nix run .#bundle-libs
  cd flutter-app
  flutter pub get
  flutter run

Flutter SDK:  $flutter_sdk_path
Android SDK:  ${androidSdk.sdkRoot}
EOF
            '';
          };
        });
    };
}
