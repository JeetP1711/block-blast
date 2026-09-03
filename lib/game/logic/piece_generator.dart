import 'dart:math';
import '../models/block.dart';
import '../models/block_shape.dart';
import 'collision_detector.dart';
import '../../utils/constants.dart';

/// Generates random game pieces with difficulty scaling.
class PieceGenerator {
  final Random _random = Random();
  int _generationCount = 0;

  /// Generate 3 new pieces.
  /// [board] is used to ensure at least one piece can be placed.
  /// [score] is used to scale difficulty.
  List<GamePiece> generatePieces(List<List<BoardCell>> board, int score) {
    _generationCount++;

    final shapes = _getShapePool(score);
    final pieces = <GamePiece>[];

    for (int i = 0; i < 3; i++) {
      final shape = shapes[_random.nextInt(shapes.length)];
      final colorIndex = _random.nextInt(AppColors.blockColors.length);
      pieces.add(GamePiece(
        shape: shape,
        colorIndex: colorIndex,
        id: '${_generationCount}_$i',
      ));
    }

    // Ensure at least one piece can be placed
    bool anyCanFit = false;
    for (final piece in pieces) {
      if (CollisionDetector.canPlaceAnywhere(board, piece.shape)) {
        anyCanFit = true;
        break;
      }
    }

    // If no piece fits, replace the first one with a small piece that can fit
    if (!anyCanFit) {
      final smallShapes = [
        BlockShapes.single,
        BlockShapes.line2H,
        BlockShapes.line2V,
      ];
      for (final small in smallShapes) {
        if (CollisionDetector.canPlaceAnywhere(board, small)) {
          pieces[0] = GamePiece(
            shape: small,
            colorIndex: _random.nextInt(AppColors.blockColors.length),
            id: '${_generationCount}_rescue',
          );
          break;
        }
      }
    }

    return pieces;
  }

  /// Get shape pool based on current score (difficulty scaling).
  List<BlockShape> _getShapePool(int score) {
    if (score < 500) {
      // Early game: mostly easy + some medium
      return [
        ...BlockShapes.easyShapes,
        ...BlockShapes.easyShapes, // double weight
        ...BlockShapes.mediumShapes,
      ];
    } else if (score < 2000) {
      // Mid game: balanced
      return [
        ...BlockShapes.easyShapes,
        ...BlockShapes.mediumShapes,
        ...BlockShapes.mediumShapes,
        ...BlockShapes.hardShapes,
      ];
    } else {
      // Late game: more hard pieces
      return [
        ...BlockShapes.easyShapes,
        ...BlockShapes.mediumShapes,
        ...BlockShapes.hardShapes,
        ...BlockShapes.hardShapes,
      ];
    }
  }
}
