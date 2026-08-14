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

abstract class TicTacToeApi {
  Future<Object> newGame(int humanMarkCode);

  Future<void> freeGame(Object handle);

  Future<int> currentPlayer(Object handle);

  Future<int> cellAt(Object handle, int index);

  Future<int> gameState(Object handle);

  Future<int> makeMove(Object handle, int index);

  Future<int> bestMove(Object handle, int difficultyCode);
}
