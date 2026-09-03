import 'package:flutter/material.dart';
import '../models/block.dart';
import 'block_widget.dart';
import '../../utils/constants.dart';

/// Renders a game piece as a mini grid of blocks.
class PiecePreview extends StatelessWidget {
  final GamePiece piece;
  final double cellSize;
  final bool dimmed;

  const PiecePreview({
    super.key,
    required this.piece,
    required this.cellSize,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (piece.isPlaced) {
      return SizedBox(
        width: piece.shape.width * (cellSize + AppConstants.gridSpacing),
        height: piece.shape.height * (cellSize + AppConstants.gridSpacing),
      );
    }

    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: SizedBox(
        width: piece.shape.width * (cellSize + AppConstants.gridSpacing),
        height: piece.shape.height * (cellSize + AppConstants.gridSpacing),
        child: Stack(
          children: piece.shape.cells.map((cell) {
            return Positioned(
              left: cell.col * (cellSize + AppConstants.gridSpacing),
              top: cell.row * (cellSize + AppConstants.gridSpacing),
              child: BlockWidget(
                colorSet: piece.colorSet,
                size: cellSize,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
