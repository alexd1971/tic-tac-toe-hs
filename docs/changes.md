# Changes

## Unreleased

### Nix-managed Flutter and Android SDKs

The Flutter dev shell now provides both Flutter and Android SDKs from Nix.
No manual Flutter checkout or Android SDK installation is required — `nix
develop` materialises a writable symlink farm for the Flutter SDK (used
directly, read-only, for the Android SDK) and writes
`flutter-gui/flutter-app/android/local.properties` automatically. See
`flutter-haskell-bridge/docs/nix-managed-sdks.md` for details.

### Flutter GUI example

Added the Flutter UI layer under `flutter-gui/flutter-app/`:

- Scaffolded for Android and Linux desktop. Path dependency on the sibling
  `flutter-haskell-bridge/` package.
- High-level Dart wrapper `flutter-gui/flutter-app/lib/tic_tac_toe_game.dart`
  over the generated `HaskellApi`: typed `Mark`, `Difficulty`, `BoardState`, and `GameError`
  enums, `TicTacToeGame` owning the `StablePtr` handle with `dispose()`.
- Setup screen (difficulty + side selection) and game screen (3x3 board, AI
  moves, win/draw detection with winning-line highlight, in-place restart).
- Smoke widget test for the setup screen.

### Flutter/Haskell layout

Renamed and aligned the Flutter/Haskell integration directories with the
`flutter-haskell-bridge` template:

- top-level Flutter integration directory: `flutter-app/` -> `flutter-gui/`;
- Flutter application package: `flutter-gui/flutter-app/`;
- Flutter FFI plugin package: `flutter-gui/flutter-haskell-bridge/`;
- Haskell FFI package: `flutter-gui/haskell-ffi/`;
- app-specific Haskell package wiring: `flutter-gui/haskell-packages.nix`.

The bridge input now comes from GitHub:
`github:alexd1971/flutter-haskell-bridge`.

### Android and native artifact bundling

The Flutter/Haskell flake now builds both Android and native desktop artifacts.
Use `bundle-libs` from `flutter-gui/`:

```bash
nix run .#bundle-libs -- all
nix run .#bundle-libs -- android
nix run .#bundle-libs -- native
```

The Dart API is generated once because Android and native builds export the
same FFI symbols.

### Binary cache

The first Flutter/Haskell build may otherwise spend a long time building GHC
toolchains used by `th-cross`. The README now recommends enabling the Cachix
cache before building:

```bash
cachix use alambdan
```

### Bridge wrapper relocation

Moved the high-level Dart wrapper from `flutter-haskell-bridge/lib/` to
`flutter-gui/flutter-app/lib/`. The bridge
package is now a pure FFI projection of the generated manifest
(`tic_tac_toe_api.dart` + barrel) and is safe to regenerate without losing
domain logic.

### Runtime initialization

`haskell_init` was undefined at runtime because the consumer did not expose the
RTS init symbol that the generated Dart API calls in its constructor. Added
`cbits/haskell_runtime.c` (copied from `flutter-haskell-bridge` templates) and
`c-sources` to `tic-tac-toe-ffi.cabal`. See
`flutter-haskell-bridge/docs/runtime-auto-init.md` for the contract.

### LateInitializationError fix

`_startNewGame` in the game screen disposed the `late` `_game` field on the
first call from `initState`, triggering `LateInitializationError`. Added an
`_initialized` guard so `dispose` and `_startNewGame` only dispose the game
when it has been created.

### Restart clears the board in place

The refresh button now starts a new game with the same difficulty/side instead
of popping back to the setup screen. AI's first move is scheduled automatically
when the AI side starts.

### Lock file refresh

Refreshed `flutter-haskell-bridge` and `haskell-ffi-th` flake inputs. The
`haskell-ffi-th` lock was stale: it pointed at a pre-rename version using
`FLUTTER_HASKELL_FFI_*` env vars while `haskell-ffi-th` had already renamed
them to `HASKELL_FFI_*`, so the FFI manifest was not emitted during the build
(see `haskell-ffi-th/docs/changes.md`).
