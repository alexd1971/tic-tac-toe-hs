import 'dart:ffi';

import 'package:tic_tac_toe_bridge/bridge.dart';

import 'base.dart';

TicTacToeApi createTicTacToeApi({String? libraryPath, Uri? serverUri}) {
  return FfiTicTacToeApi(libraryPath: libraryPath);
}

class FfiTicTacToeApi implements TicTacToeApi {
  FfiTicTacToeApi({String? libraryPath}) : _api = HaskellApi(libraryPath);

  final HaskellApi _api;

  @override
  Future<Object> newGame(int humanMarkCode) async {
    return _api.newGame(humanMarkCode);
  }

  @override
  Future<void> freeGame(Object handle) async {
    _api.freeGame(_asPointer(handle));
  }

  @override
  Future<int> currentPlayer(Object handle) async {
    return _api.currentPlayer(_asPointer(handle));
  }

  @override
  Future<int> cellAt(Object handle, int index) async {
    return _api.cellAt(_asPointer(handle), index);
  }

  @override
  Future<int> gameState(Object handle) async {
    return _api.gameState(_asPointer(handle));
  }

  @override
  Future<int> makeMove(Object handle, int index) async {
    return _api.makeMove(_asPointer(handle), index);
  }

  @override
  Future<int> bestMove(Object handle, int difficultyCode) async {
    return _api.bestMove(_asPointer(handle), difficultyCode);
  }

  Pointer<Void> _asPointer(Object handle) {
    return handle as Pointer<Void>;
  }
}
