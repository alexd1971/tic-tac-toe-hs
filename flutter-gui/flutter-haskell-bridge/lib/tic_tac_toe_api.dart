// Generated from the Haskell FFI manifest.
// Do not edit manually.

import 'dart:ffi' as ffi;
import 'dart:io' as io;

class HaskellApi {
  HaskellApi([String? libraryPath])
      : _library = ffi.DynamicLibrary.open(libraryPath ?? _defaultLibraryPath()) {
    _initializeRuntime();
  }

  static const libraryName = 'tic_tac_toe';
  static const libraryFileName = 'libtic_tac_toe.so';

  final ffi.DynamicLibrary _library;

  static String _defaultLibraryPath() {
    if (io.Platform.isLinux) {
      return '${io.File(io.Platform.resolvedExecutable).parent.path}/lib/$libraryFileName';
    }
    return libraryFileName;
  }

  late final _initializeRuntime = _library
      .lookupFunction<ffi.Void Function(), void Function()>('haskell_init');

  late final _newGame = _library
      .lookupFunction<ffi.Pointer<ffi.Void> Function(ffi.Int32), ffi.Pointer<ffi.Void> Function(int)>('tic_tac_toe_new_game');

  ffi.Pointer<ffi.Void> newGame(int arg0) {
    return _newGame(arg0);
  }

  late final _freeGame = _library
      .lookupFunction<ffi.Void Function(ffi.Pointer<ffi.Void>), void Function(ffi.Pointer<ffi.Void>)>('tic_tac_toe_free_game');

  void freeGame(ffi.Pointer<ffi.Void> arg0) {
    _freeGame(arg0);
  }

  late final _currentPlayer = _library
      .lookupFunction<ffi.Int32 Function(ffi.Pointer<ffi.Void>), int Function(ffi.Pointer<ffi.Void>)>('tic_tac_toe_current_player');

  int currentPlayer(ffi.Pointer<ffi.Void> arg0) {
    return _currentPlayer(arg0);
  }

  late final _cellAt = _library
      .lookupFunction<ffi.Int32 Function(ffi.Pointer<ffi.Void>, ffi.Int32), int Function(ffi.Pointer<ffi.Void>, int)>('tic_tac_toe_cell_at');

  int cellAt(ffi.Pointer<ffi.Void> arg0, int arg1) {
    return _cellAt(arg0, arg1);
  }

  late final _gameState = _library
      .lookupFunction<ffi.Int32 Function(ffi.Pointer<ffi.Void>), int Function(ffi.Pointer<ffi.Void>)>('tic_tac_toe_game_state');

  int gameState(ffi.Pointer<ffi.Void> arg0) {
    return _gameState(arg0);
  }

  late final _makeMove = _library
      .lookupFunction<ffi.Int32 Function(ffi.Pointer<ffi.Void>, ffi.Int32), int Function(ffi.Pointer<ffi.Void>, int)>('tic_tac_toe_make_move');

  int makeMove(ffi.Pointer<ffi.Void> arg0, int arg1) {
    return _makeMove(arg0, arg1);
  }

  late final _bestMove = _library
      .lookupFunction<ffi.Int32 Function(ffi.Pointer<ffi.Void>, ffi.Int32), int Function(ffi.Pointer<ffi.Void>, int)>('tic_tac_toe_best_move');

  int bestMove(ffi.Pointer<ffi.Void> arg0, int arg1) {
    return _bestMove(arg0, arg1);
  }
}
