import '../models/block.dart';
import '../../utils/constants.dart';

/// Handles collision detection for piece placement on the board.
class CollisionDetector {
  /// Check if a piece can be placed at the given position.
  static bool canPlace(
    List<List<BoardCell>> board,
    BlockShape shape,
    int startRow,
    int startCol,
  ) {
    for (final cell in shape.cells) {
      final row = startRow + cell.row;
      final col = startCol + cell.col;

      // Out of bounds
      if (row < 0 || row >= AppConstants.gridSize ||
          col < 0 || col >= AppConstants.gridSize) {
        return false;
      }

      // Already occupied
      if (board[row][col].occupied) {
        return false;
      }
    }
    return true;
  }

  /// Check if a piece can be placed anywhere on the board.
  static bool canPlaceAnywhere(
    List<List<BoardCell>> board,
    BlockShape shape,
  ) {
    for (int row = 0; row <= AppConstants.gridSize - 1; row++) {
      for (int col = 0; col <= AppConstants.gridSize - 1; col++) {
        if (canPlace(board, shape, row, col)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Check if any of the given pieces can be placed on the board.
  static bool canPlaceAny(
    List<List<BoardCell>> board,
    List<GamePiece> pieces,
  ) {
    for (final piece in pieces) {
      if (!piece.isPlaced && canPlaceAnywhere(board, piece.shape)) {
        return true;
      }
    }
    return false;
  }

  /// Find which rows are completely filled.
  static List<int> findFullRows(List<List<BoardCell>> board) {
    final fullRows = <int>[];
    for (int row = 0; row < AppConstants.gridSize; row++) {
      bool full = true;
      for (int col = 0; col < AppConstants.gridSize; col++) {
        if (!board[row][col].occupied) {
          full = false;
          break;
        }
      }
      if (full) fullRows.add(row);
    }
    return fullRows;
  }

  /// Find which columns are completely filled.
  static List<int> findFullCols(List<List<BoardCell>> board) {
    final fullCols = <int>[];
    for (int col = 0; col < AppConstants.gridSize; col++) {
      bool full = true;
      for (int row = 0; row < AppConstants.gridSize; row++) {
        if (!board[row][col].occupied) {
          full = false;
          break;
        }
      }
      if (full) fullCols.add(col);
    }
    return fullCols;
  }

  /// Get all cells that would be cleared (combining full rows and columns).
  static Set<BlockCell> getCellsToClear(List<List<BoardCell>> board) {
    final cells = <BlockCell>{};
    final fullRows = findFullRows(board);
    final fullCols = findFullCols(board);

    for (final row in fullRows) {
      for (int col = 0; col < AppConstants.gridSize; col++) {
        cells.add(BlockCell(row, col));
      }
    }

    for (final col in fullCols) {
      for (int row = 0; row < AppConstants.gridSize; row++) {
        cells.add(BlockCell(row, col));
      }
    }

    return cells;
  }
}
