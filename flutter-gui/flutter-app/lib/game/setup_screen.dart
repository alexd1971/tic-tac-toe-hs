import 'package:flutter/material.dart';
import '../tic_tac_toe_game.dart';

import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  Difficulty _difficulty = Difficulty.hard;
  Mark _humanMark = Mark.x;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text('Difficulty', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<Difficulty>(
                  segments: const [
                    ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
                    ButtonSegment(
                      value: Difficulty.medium,
                      label: Text('Medium'),
                    ),
                    ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
                  ],
                  selected: {_difficulty},
                  onSelectionChanged: (s) =>
                      setState(() => _difficulty = s.first),
                ),
                const SizedBox(height: 32),
                Text('Your mark', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<Mark>(
                  segments: const [
                    ButtonSegment(value: Mark.x, label: Text('X (first)')),
                    ButtonSegment(value: Mark.o, label: Text('O (second)')),
                  ],
                  selected: {_humanMark},
                  onSelectionChanged: (s) =>
                      setState(() => _humanMark = s.first),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GameScreen(
                        difficulty: _difficulty,
                        humanMark: _humanMark,
                      ),
                    ),
                  ),
                  child: const Text('Start game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
