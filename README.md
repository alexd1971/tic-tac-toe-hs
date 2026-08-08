# Tic-tac-toe Haskell

This repository is a working example of using
[`flutter-haskell-bridge`](https://github.com/alexd1971/flutter-haskell-bridge)
to call a Haskell library from a Flutter application.

The example keeps the game logic in Haskell, exposes it through a small FFI
package, bundles the resulting native libraries into a Flutter plugin, and uses
that plugin from a Flutter UI. The same Haskell core is also used by a native
CLI, so the domain logic can be built and tested without Flutter or Android.

## Directory layout

- `haskell-core`: pure tic-tac-toe domain logic and AI.
- `haskell-cli`: native console application using `haskell-core`.
- `flutter-gui`: Flutter/Haskell integration layer.
  - `flutter-app`: the end-user Flutter application.
  - `flutter-haskell-bridge`: local Flutter plugin package that contains the
    generated Dart FFI API and bundled native libraries.
  - `haskell-ffi`: Haskell FFI wrapper around `haskell-core`.
  - `haskell-packages.nix`: app-specific Haskell package wiring used by the
    bridge build.

The Flutter layer is intentionally separate from the core library. In a real
application, the Haskell library does not have to live inside the Flutter
project; it can be a sibling directory, a separate repository, or another Nix
input.

## Requirements

- Nix with flakes enabled.
- Linux `x86_64-linux` for the Linux desktop build shown below.
- Android device or emulator for `flutter run -d <android-device>`.
- Git, because the flakes depend on GitHub inputs.

The Flutter SDK, Android SDK, JDK, Cabal, `cabal2nix`, and the Dart FFI
generator are provided by the `flutter-gui` Nix development shell. You do not
need a separately installed Android SDK for the commands below.

The Android example currently targets `aarch64-android` / `arm64-v8a`.

## Build time and binary cache

The first Flutter/Haskell build can take a long time. The cross-compilation
stack uses several large GHC/toolchain outputs: a patched host compiler for the
Template Haskell worker, a target cross-GHC for Android, and the native GHC used
for desktop artifacts. If they are not available from a binary substituter, Nix
has to build them locally.

For regular use, publishing those toolchains and build artifacts to a binary
cache such as Cachix is recommended. Configure the cache before running
`bundle-libs`; otherwise the first build may spend most of its time compiling
the toolchain instead of the example application.

The cache is not enabled automatically by this flake. If you want to use the
binary cache for this example, enable it explicitly before building:

```bash
cachix use alambdan
```

## Build workflow

There are two flakes:

- the repository root flake builds the native Haskell CLI;
- `flutter-gui/flake.nix` builds and bundles Flutter/Haskell artifacts.

### 1. Build and test the Haskell core

From the repository root:

```bash
nix develop -c cabal test all
nix run
```

`nix run` starts the native `tic-tac-toe` CLI.

### 2. Enter the Flutter/Haskell shell

```bash
cd flutter-gui
nix develop
```

The shell sets `ANDROID_HOME` and `ANDROID_SDK_ROOT`, and writes
`flutter-app/android/local.properties` for Gradle.

### 3. Regenerate Haskell package Nix files when Cabal files change

Run this only after changing Haskell package metadata, dependencies, or source
layout:

```bash
nix run .#regen-haskell-nix
```

This regenerates the Nix expressions listed in `haskell-packages.nix`.

### 4. Build and bundle FFI artifacts

To build both Android and native desktop artifacts:

```bash
nix run .#bundle-libs -- all
```

To build only one target:

```bash
nix run .#bundle-libs -- android
nix run .#bundle-libs -- native
```

The command updates the Flutter plugin package under
`flutter-gui/flutter-haskell-bridge`:

- `android/src/main/jniLibs/arm64-v8a`: Android JNI libraries;
- `linux/lib`: Linux shared libraries;
- `lib/tic_tac_toe_api.dart`: generated Dart FFI bindings.

The Dart API is generated once because Android and native builds export the
same FFI symbols.

### 5. Fetch Flutter dependencies

```bash
cd flutter-app
flutter pub get
```

The app depends on the local plugin package:

```yaml
flutter_haskell_bridge:
  path: ../flutter-haskell-bridge
```

### 6. Run checks

```bash
flutter analyze
flutter test
```

### 7. Build or run Linux desktop

```bash
flutter build linux --debug
flutter run -d linux
```

If the project was moved or renamed and CMake reports paths from an old
checkout location, clear Flutter's generated build state:

```bash
flutter clean
flutter pub get
flutter build linux --debug
```

### 8. Build or run Android

List devices:

```bash
flutter devices
```

Build a debug APK:

```bash
flutter build apk --debug
```

Run on a connected Android device or emulator:

```bash
flutter run -d <device-id>
```

## Important files

- `flutter-gui/flake.nix`: connects this application to
  `flutter-haskell-bridge`, `template-haskell-cross`, and `haskell-ffi-th`.
- `flutter-gui/haskell-packages.nix`: declares local Haskell packages and the
  package files that can be regenerated with `regen-haskell-nix`.
- `flutter-gui/haskell-ffi/src/TicTacToe/FFI.hs`: exported Haskell FFI surface.
- `flutter-gui/flutter-haskell-bridge/lib/tic_tac_toe_bridge.dart`: barrel
  export for the generated FFI API.
- `flutter-gui/flutter-app/lib/tic_tac_toe_game.dart`: high-level Dart wrapper
  around the generated API.
- `flutter-gui/flutter-app/lib/game`: Flutter UI.

## External dependencies

The Flutter/Haskell integration uses GitHub inputs:

- [`flutter-haskell-bridge`](https://github.com/alexd1971/flutter-haskell-bridge)
- [`template-haskell-cross`](https://github.com/alexd1971/template-haskell-cross)
- [`haskell-ffi-th`](https://github.com/alexd1971/haskell-ffi-th)

`haskell-ffi-th` is used to define and generate the Haskell FFI layer. The
bridge tooling then builds the Haskell shared libraries and generates the Dart
FFI API consumed by Flutter.
