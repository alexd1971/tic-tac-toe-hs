# Tic-tac-toe Haskell

This repository is a working example of using
[`flutter-haskell-bridge`](https://github.com/alexd1971/flutter-haskell-bridge)
to call a Haskell library from a Flutter application.

The example keeps the game logic in Haskell and exposes it to Flutter in two
ways:

- native desktop and Android use `flutter-haskell-bridge` and a generated FFI
  API;
- Flutter web uses an HTTP API served by a Haskell `servant` server.

The same Haskell core is also used by a native CLI, so the domain logic can be
built and tested without Flutter, Android, or a browser.

## Directory layout

- `haskell-core`: pure tic-tac-toe domain logic and AI.
- `haskell-cli`: native console application using `haskell-core`.
- `haskell-server`: HTTP API server using `servant` and `warp`.
- `flutter-gui`: Flutter/Haskell integration layer.
  - `flutter-app`: the end-user Flutter application.
  - `flutter-haskell-bridge`: local Flutter FFI package that contains the
    generated Dart FFI API and bundled native assets.
  - `haskell-ffi`: Haskell FFI wrapper around `haskell-core`.
  - `haskell-packages.nix`: app-specific Haskell package wiring used by the
    bridge build.

The Flutter layer is intentionally separate from the core library. In a real
application, the Haskell library does not have to live inside the Flutter
project; it can be a sibling directory, a separate repository, or another Nix
input. The web server follows the same rule: it is just another consumer of the
core library.

## Requirements

- Nix with flakes enabled.
- Linux `x86_64-linux` for the Linux desktop build shown below.
- Android device or emulator for `flutter run -d <android-device>`.
- Git, because the flakes depend on GitHub inputs.

The Flutter SDK, Android SDK, JDK, Cabal, `cabal2nix`, and the Dart FFI
generator are provided by the `flutter-gui` Nix development shell. You do not
need a separately installed Android SDK for the commands below.

The Android example currently targets `aarch64-android` / `arm64-v8a`.

For Flutter web, use a browser supported by your Flutter SDK. In release mode,
the Haskell server can serve both the static Flutter web bundle and the HTTP API:
static files are served from `/`, and the game API is served under `/api`.

By default the web UI uses the same origin `/api/` endpoint. When running
Flutter web from the Flutter development server while the Haskell API server is
running separately, override the API URL:

```bash
--dart-define=API_BASE_URL=http://host:port/api/
```

## Binary cache

The first build may be slow because Nix has to fetch or build the Haskell,
Flutter, Android, and cross-compilation toolchains. Use the project Cachix cache
before running `bundle-libs` or release builds:

```bash
cachix use alambdan
```

## Usage workflow

There are two flakes:

- the repository root flake builds the native Haskell CLI and HTTP server;
- `flutter-gui/flake.nix` builds and bundles Flutter/Haskell artifacts.

### Shared Haskell checks

From the repository root:

```bash
nix develop -c cabal test all
nix run
```

`nix run` starts the native `tic-tac-toe` CLI.

### Native and Android development

```bash
cd flutter-gui
nix develop
```

The shell sets `ANDROID_HOME` and `ANDROID_SDK_ROOT`, and writes
`flutter-app/android/local.properties` for Gradle.

Regenerate Haskell package Nix files only after changing Haskell package
metadata, dependencies, or source layout:

```bash
nix run .#regen-haskell-nix
```

This regenerates the Nix expressions listed in `haskell-packages.nix`.

Build and bundle FFI artifacts for native desktop and Android:

```bash
nix run .#bundle-libs -- all
```

To build only one target:

```bash
nix run .#bundle-libs -- android
nix run .#bundle-libs -- native
```

The command updates the Flutter FFI package under
`flutter-gui/flutter-haskell-bridge`:

- `native_assets/android/arm64-v8a`: Android shared libraries;
- `native_assets/linux`: Linux shared libraries;
- `lib/bridge.dart`: generated Dart FFI bindings.

The Dart API is generated once because Android and native builds export the
same FFI symbols.

Fetch Flutter dependencies:

```bash
cd flutter-app
flutter pub get
```

The app depends on the local FFI package:

```yaml
tic_tac_toe_bridge:
  path: ../flutter-haskell-bridge
```

Run checks:

```bash
flutter analyze
flutter test
```

Build or run Linux desktop:

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

Build or run Android:

```bash
flutter devices
flutter build apk --debug
flutter run -d <device-id>
```

### Flutter web development

During development, run the Haskell HTTP API server and Flutter's web dev
server separately.

In the first shell, from the repository root:

```bash
nix run .#server
```

The server listens on `http://127.0.0.1:8081`, serves API routes under `/api`,
and may also serve static files when `STATIC_DIR` is set.

In the second shell:

```bash
cd flutter-gui/flutter-app
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081/api/
```

If the API server runs on another port, adjust the Dart define:

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://127.0.0.1:8090/api/
```

### Web release without a container

Build the static Flutter web bundle with Nix:

```bash
nix build .#web
```

Run the Haskell server against that bundle:

```bash
STATIC_DIR="$PWD/result" nix run .#server
```

The server serves:

- `GET /`: Flutter web application;
- `GET/POST/DELETE /api/...`: game API used by the web application.

Use `PORT` to override the default `8081`:

```bash
PORT=8090 STATIC_DIR="$PWD/result" nix run .#server
```

### Web release as an image

The `web-app-image` output packages:

- builds the Flutter web bundle with Nix;
- packages the `tic-tac-toe-server` executable and its runtime closure;
- packages the generated Flutter static files under `/app/static`.

You can build the web bundle separately:

```bash
nix build .#web
```

Or build the final Docker-compatible OCI image directly:

```bash
nix build .#web-app-image
```

The image build does not compile anything inside the container; Flutter web and
the Haskell server are built by Nix before the image is assembled.

Load and run with Docker-compatible tooling:

```bash
docker load < result
docker run --rm -p 8081:8081 tic-tac-toe-hs:latest
```

The image sets:

```text
PORT=8081
STATIC_DIR=/app/static
```

## Entry points

- Root flake:
  - `nix run`: run the CLI.
  - `nix run .#server`: run the HTTP/web server.
  - `nix build .#web`: build Flutter web static files.
  - `nix build .#web-app-image`: build the Docker-compatible web image.
- `flutter-gui` flake:
  - `nix develop`: enter the Flutter/Haskell development shell.
  - `nix run .#bundle-libs -- all`: build and copy native/Android FFI
    artifacts into the Flutter FFI package.
  - `nix run .#regen-haskell-nix`: regenerate app-specific Cabal-to-Nix files.

## External dependencies

The Flutter/Haskell integration uses GitHub inputs:

- [`flutter-haskell-bridge`](https://github.com/alexd1971/flutter-haskell-bridge)
- [`template-haskell-cross`](https://github.com/alexd1971/template-haskell-cross)
- [`haskell-ffi-th`](https://github.com/alexd1971/haskell-ffi-th)

`haskell-ffi-th` is used to define and generate the Haskell FFI layer. The
bridge tooling then builds the Haskell shared libraries and generates the Dart
FFI API consumed by Flutter.
