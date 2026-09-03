import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../logic/game_engine.dart';
import 'block_widget.dart';
import '../../utils/constants.dart';

/// The 9x9 game board widget.
class GameBoardWidget extends StatelessWidget {
  final GameEngine engine;
  final double boardSize;

  const GameBoardWidget({
    super.key,
    required this.engine,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    final padding = 8.0;
    final innerSize = boardSize - padding * 2;
    final cellSize =
        (innerSize - (AppConstants.gridSize - 1) * AppConstants.gridSpacing) /
            AppConstants.gridSize;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: AppColors.gridBg,
        borderRadius: BorderRadius.circular(AppConstants.gridBorderRadius),
        border: Border.all(
          color: AppColors.gridBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.buttonGlow.withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Stack(
        children: [
          // Grid cells
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(AppConstants.gridSize, (row) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: row < AppConstants.gridSize - 1
                      ? AppConstants.gridSpacing
                      : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(AppConstants.gridSize, (col) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: col < AppConstants.gridSize - 1
                            ? AppConstants.gridSpacing
                            : 0,
                      ),
                      child: _buildCell(row, col, cellSize),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    final cell = engine.board[row][col];

    // Check if this cell is in the preview
    bool isPreview = false;
    bool previewValid = false;
    BlockColorSet? previewColor;

    if (engine.state == GameState.dragging &&
        engine.dragPieceIndex != null &&
        engine.previewRow != null &&
        engine.previewCol != null) {
      final piece = engine.currentPieces[engine.dragPieceIndex!];
      for (final bc in piece.shape.cells) {
        if (engine.previewRow! + bc.row == row &&
            engine.previewCol! + bc.col == col) {
          isPreview = true;
          previewValid = engine.previewValid;
          previewColor = piece.colorSet;
          break;
        }
      }
    }

    if (cell.occupied) {
      if (cell.clearing) {
        return _ClearingCellAnimation(
          colorSet: cell.colorSet!,
          size: cellSize,
        );
      }
      return BlockWidget(
        colorSet: cell.colorSet!,
        size: cellSize,
      );
    }

    if (isPreview) {
      if (previewValid && previewColor != null) {
        return BlockWidget(
          colorSet: previewColor,
          size: cellSize,
          opacity: 0.5,
        );
      }
      return PreviewCellWidget(
        size: cellSize,
        valid: previewValid,
      );
    }

    return EmptyCellWidget(size: cellSize);
  }
}

class _ClearingCellAnimation extends StatefulWidget {
  final BlockColorSet colorSet;
  final double size;

  const _ClearingCellAnimation({
    required this.colorSet,
    required this.size,
  });

  @override
  State<_ClearingCellAnimation> createState() => _ClearingCellAnimationState();
}

class _ClearingCellAnimationState extends State<_ClearingCellAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.clearDuration,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: BlockWidget(
            colorSet: widget.colorSet,
            size: widget.size,
            clearing: true,
            opacity: _opacity.value,
          ),
        );
      },
    );
  }
}
