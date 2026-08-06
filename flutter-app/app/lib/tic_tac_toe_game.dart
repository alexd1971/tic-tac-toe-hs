import 'dart:ffi';

import 'package:tic_tac_toe_bridge/tic_tac_toe_bridge.dart';

enum Mark {
  x(1),
  o(2);

  const Mark(this.code);

  final int code;

  static Mark fromCode(int code) {
    return switch (code) {
      2 => Mark.o,
      _ => Mark.x,
    };
  }

  Mark get other => this == Mark.x ? Mark.o : Mark.x;
}

enum Difficulty {
  easy(1),
  medium(2),
  hard(3);

  const Difficulty(this.code);

  final int code;
}

enum BoardState {
  inProgress(0),
  draw(1),
  winX(2),
  winO(3);

  const BoardState(this.code);

  final int code;

  static BoardState fromCode(int code) {
    return switch (code) {
      1 => BoardState.draw,
      2 => BoardState.winX,
      3 => BoardState.winO,
      _ => BoardState.inProgress,
    };
  }

  Mark? get winner {
    return switch (this) {
      BoardState.winX => Mark.x,
      BoardState.winO => Mark.o,
      _ => null,
    };
  }
}

enum GameError {
  outOfBounds(1),
  occupied(2),
  gameOver(3);

  const GameError(this.code);

  final int code;

  static GameError? fromCode(int code) {
    return switch (code) {
      1 => GameError.outOfBounds,
      2 => GameError.occupied,
      3 => GameError.gameOver,
      _ => null,
    };
  }

  String get description {
    return switch (this) {
      GameError.outOfBounds => 'Cell is out of bounds',
      GameError.occupied => 'Cell is already occupied',
      GameError.gameOver => 'Game is already over',
    };
  }
}

class TicTacToeGame {
  TicTacToeGame._(this._api, this._handle);

  factory TicTacToeGame({
    required Mark humanMark,
    String libraryPath = 'libtic_tac_toe.so',
  }) {
    final api = HaskellApi(libraryPath);
    final handle = api.newGame(humanMark.code);
    return TicTacToeGame._(api, handle);
  }

  final HaskellApi _api;
  final Pointer<Void> _handle;
  bool _disposed = false;

  Mark get currentPlayer {
    _ensureNotDisposed();
    return Mark.fromCode(_api.currentPlayer(_handle));
  }

  BoardState get state {
    _ensureNotDisposed();
    return BoardState.fromCode(_api.gameState(_handle));
  }

  Mark? cellAt(int index) {
    _ensureNotDisposed();
    final code = _api.cellAt(_handle, index);
    return code == 0 ? null : Mark.fromCode(code);
  }

  GameError? makeMove(int index) {
    _ensureNotDisposed();
    return GameError.fromCode(_api.makeMove(_handle, index));
  }

  int? bestMove(Difficulty difficulty) {
    _ensureNotDisposed();
    final index = _api.bestMove(_handle, difficulty.code);
    return index < 0 ? null : index;
  }

  List<Mark?> board() {
    _ensureNotDisposed();
    return List<Mark?>.generate(9, cellAt);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _api.freeGame(_handle);
    _disposed = true;
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('TicTacToeGame has been disposed');
    }
  }
}
