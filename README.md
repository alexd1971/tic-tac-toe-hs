# Tic-tac-toe Haskell

Realistic integration example for the Template Haskell cross-compilation stack.

The repository is split into three layers:

- `haskell-core`: pure tic-tac-toe domain logic and AI.
- `haskell-cli`: native console application using `haskell-core`.
- `flutter-app`: Android Flutter application using the same core through FFI.

The Flutter layer is intentionally separate from the core library so the core can
be tested natively before it is cross-compiled.
