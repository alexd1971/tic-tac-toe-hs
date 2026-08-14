import '../api.dart';

export '../api/base.dart' show BoardState, Difficulty, GameError, Mark;

class TicTacToeGame {
  TicTacToeGame._(this._api, this._handle);

  static Future<TicTacToeGame> create({
    required Mark humanMark,
    String? libraryPath,
    Uri? serverUri,
  }) async {
    final api = createTicTacToeApi(
      libraryPath: libraryPath,
      serverUri: serverUri,
    );
    final handle = await api.newGame(humanMark.code);
    final game = TicTacToeGame._(api, handle);
    await game._refresh();
    return game;
  }

  final TicTacToeApi _api;
  final Object _handle;
  bool _disposed = false;
  late Mark _currentPlayer;
  late BoardState _state;
  late List<Mark?> _board;

  Mark get currentPlayer {
    _ensureNotDisposed();
    return _currentPlayer;
  }

  BoardState get state {
    _ensureNotDisposed();
    return _state;
  }

  Mark? cellAt(int index) {
    _ensureNotDisposed();
    return _board[index];
  }

  Future<GameError?> makeMove(int index) async {
    _ensureNotDisposed();
    final errorCode = await _api.makeMove(_handle, index);
    if (_disposed) {
      return null;
    }
    await _refresh();
    return GameError.fromCode(errorCode);
  }

  Future<int?> bestMove(Difficulty difficulty) async {
    _ensureNotDisposed();
    final index = await _api.bestMove(_handle, difficulty.code);
    if (_disposed) {
      return null;
    }
    return index < 0 ? null : index;
  }

  List<Mark?> board() {
    _ensureNotDisposed();
    return List<Mark?>.of(_board);
  }

  Future<void> refresh() async {
    _ensureNotDisposed();
    await _refresh();
  }

  Future<void> _refresh() async {
    final board = <Mark?>[];
    for (var index = 0; index < 9; index += 1) {
      final code = await _api.cellAt(_handle, index);
      if (_disposed) {
        return;
      }
      board.add(code == 0 ? null : Mark.fromCode(code));
    }
    final currentPlayer = Mark.fromCode(await _api.currentPlayer(_handle));
    if (_disposed) {
      return;
    }
    final state = BoardState.fromCode(await _api.gameState(_handle));
    if (_disposed) {
      return;
    }
    _board = board;
    _currentPlayer = currentPlayer;
    _state = state;
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    await _api.freeGame(_handle);
    _disposed = true;
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('TicTacToeGame has been disposed');
    }
  }
}
