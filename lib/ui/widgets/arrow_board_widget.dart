import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/game_board.dart';
import '../theme/app_theme.dart';
import 'arrow_tile_widget.dart';

class ArrowBoardWidget extends StatelessWidget {
  final GameBoard board;
  final String? hintArrowId;
  final Function(String arrowId)? onArrowTap;
  final Function(String arrowId)? onArrowExitComplete;

  const ArrowBoardWidget({
    super.key,
    required this.board,
    this.hintArrowId,
    this.onArrowTap,
    this.onArrowExitComplete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute optimal tile size to fit available area while preserving square grid
        final availableWidth = constraints.maxWidth - 24;
        final availableHeight = constraints.maxHeight - 24;

        final maxTileWidth = availableWidth / board.cols;
        final maxTileHeight = availableHeight / board.rows;
        final tileSize = math.min(maxTileWidth, maxTileHeight).clamp(24.0, 80.0);

        final boardWidth = tileSize * board.cols;
        final boardHeight = tileSize * board.rows;

        return Center(
          child: Container(
            width: boardWidth + 16,
            height: boardHeight + 16,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppTheme.bgDark.withAlpha(200),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryLight.withAlpha(100), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: board.cols,
                childAspectRatio: 1.0,
              ),
              itemCount: board.rows * board.cols,
              itemBuilder: (context, index) {
                final r = index ~/ board.cols;
                final c = index % board.cols;
                final arrow = board.getArrowAt(r, c);

                return ArrowTileWidget(
                  key: ValueKey('tile_${r}_${c}_${arrow?.id}'),
                  arrow: arrow,
                  tileSize: tileSize,
                  hintArrowId: hintArrowId,
                  onTap: onArrowTap,
                  onExitAnimationComplete: () {
                    if (arrow != null) {
                      onArrowExitComplete?.call(arrow.id);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
