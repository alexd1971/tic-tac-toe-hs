import 'package:flutter/material.dart';
import '../tic_tac_toe_game.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.board,
    this.winningLine,
    required this.onCellTap,
    required this.enabled,
  });

  final List<Mark?> board;
  final List<int>? winningLine;
  final ValueChanged<int> onCellTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;

        return Center(
          child: SizedBox.square(
            dimension: size,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final isWinning = winningLine?.contains(index) ?? false;
                return _Cell(
                  mark: board[index],
                  isWinning: isWinning,
                  enabled: enabled && board[index] == null,
                  onTap: () => onCellTap(index),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.mark,
    required this.isWinning,
    required this.enabled,
    required this.onTap,
  });

  final Mark? mark;
  final bool isWinning;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (mark) {
      Mark.x => scheme.primary,
      Mark.o => scheme.tertiary,
      null => scheme.outline,
    };

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isWinning
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          mark == null ? '' : mark!.name.toUpperCase(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
