import 'package:flutter/material.dart';

import '../game.dart';
import '../widgets/board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.difficulty,
    required this.humanMark,
  });

  final Difficulty difficulty;
  final Mark humanMark;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TicTacToeGame _game;
  late List<Mark?> _board;
  bool _aiThinking = false;
  bool _humanMovePending = false;
  String? _error;
  String? _startupError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    if (_initialized) {
      _game.dispose();
    }
    super.dispose();
  }

  Future<void> _startNewGame() async {
    final previousGame = _initialized ? _game : null;
    setState(() {
      _startupError = null;
      _humanMovePending = false;
    });

    late final TicTacToeGame game;
    try {
      game = await TicTacToeGame.create(humanMark: widget.humanMark);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error.toString();
        _error = _initialized ? 'Failed to start game: $error' : _error;
        _aiThinking = false;
        _humanMovePending = false;
      });
      return;
    }

    await previousGame?.dispose();

    if (!mounted) {
      await game.dispose();
      return;
    }

    final board = game.board();
    final aiStarts = game.currentPlayer != widget.humanMark;

    if (_initialized) {
      setState(() {
        _game = game;
        _board = board;
        _error = null;
        _startupError = null;
        _aiThinking = aiStarts;
        _humanMovePending = false;
      });
    } else {
      setState(() {
        _game = game;
        _board = board;
        _error = null;
        _startupError = null;
        _aiThinking = aiStarts;
        _humanMovePending = false;
        _initialized = true;
      });
    }

    if (aiStarts) {
      _scheduleAiMove();
    }
  }

  bool get _isHumanTurn =>
      !_aiThinking &&
      !_humanMovePending &&
      _game.state == BoardState.inProgress &&
      _game.currentPlayer == widget.humanMark;

  Future<void> _scheduleAiMove() async {
    final game = _game;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || !identical(game, _game)) return;

    final move = await game.bestMove(widget.difficulty);
    if (move != null) {
      await game.makeMove(move);
    }
    if (!identical(game, _game)) return;

    setState(() {
      _board = _game.board();
      _aiThinking = false;
    });
  }

  Future<void> _onCellTap(int index) async {
    if (!_isHumanTurn) return;

    final game = _game;
    setState(() => _humanMovePending = true);
    final error = await game.makeMove(index);
    if (!mounted || !identical(game, _game)) return;
    if (error != null) {
      setState(() {
        _error = error.description;
        _humanMovePending = false;
      });
      return;
    }

    final shouldScheduleAi =
        game.state == BoardState.inProgress &&
        game.currentPlayer != widget.humanMark;

    setState(() {
      _board = game.board();
      _error = null;
      _humanMovePending = false;
      if (shouldScheduleAi) _aiThinking = true;
    });

    if (shouldScheduleAi) {
      _scheduleAiMove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tic-Tac-Toe'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Retry',
              onPressed: _startNewGame,
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: _startupError == null
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to start game:\n$_startupError',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
          ),
        ),
      );
    }

    final state = _game.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New game',
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statusText(state),
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: BoardWidget(
                      board: _board,
                      winningLine: _winningLine(state),
                      onCellTap: _onCellTap,
                      enabled: _isHumanTurn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'You: ${widget.humanMark.name.toUpperCase()} · '
                    'AI: ${widget.humanMark.other.name.toUpperCase()} · '
                    'Difficulty: ${widget.difficulty.name}',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusText(BoardState state) {
    if (_aiThinking) return 'AI is thinking...';
    return switch (state) {
      BoardState.inProgress =>
        _isHumanTurn
            ? 'Your turn (${widget.humanMark.name.toUpperCase()})'
            : 'AI turn (${_game.currentPlayer.name.toUpperCase()})',
      BoardState.draw => "It's a draw!",
      BoardState.winX => widget.humanMark == Mark.x ? 'You win!' : 'AI wins!',
      BoardState.winO => widget.humanMark == Mark.o ? 'You win!' : 'AI wins!',
    };
  }

  List<int>? _winningLine(BoardState state) {
    final winner = state.winner;
    if (winner == null) return null;

    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      if (line.every((i) => _board[i] == winner)) {
        return line;
      }
    }
    return null;
  }
}
