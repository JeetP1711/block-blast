import '../../utils/constants.dart';

/// Represents a single cell position in a block shape.
class BlockCell {
  final int row;
  final int col;

  const BlockCell(this.row, this.col);

  BlockCell operator +(BlockCell other) => BlockCell(row + other.row, col + other.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BlockCell && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'BlockCell($row, $col)';
}

/// Represents a block shape definition.
class BlockShape {
  final String name;
  final List<BlockCell> cells;

  const BlockShape({required this.name, required this.cells});

  int get width {
    int maxCol = 0;
    for (final cell in cells) {
      if (cell.col > maxCol) maxCol = cell.col;
    }
    return maxCol + 1;
  }

  int get height {
    int maxRow = 0;
    for (final cell in cells) {
      if (cell.row > maxRow) maxRow = cell.row;
    }
    return maxRow + 1;
  }

  int get cellCount => cells.length;
}

/// A piece with shape and color.
class GamePiece {
  final BlockShape shape;
  final int colorIndex;
  final String id;
  bool isPlaced;

  GamePiece({
    required this.shape,
    required this.colorIndex,
    required this.id,
    this.isPlaced = false,
  });

  BlockColorSet get colorSet => AppColors.blockColors[colorIndex % AppColors.blockColors.length];

  GamePiece copyWith({bool? isPlaced}) {
    return GamePiece(
      shape: shape,
      colorIndex: colorIndex,
      id: id,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}

/// Represents a cell on the game board.
class BoardCell {
  final bool occupied;
  final int colorIndex;
  final bool clearing;

  const BoardCell({
    this.occupied = false,
    this.colorIndex = 0,
    this.clearing = false,
  });

  BoardCell copyWith({bool? occupied, int? colorIndex, bool? clearing}) {
    return BoardCell(
      occupied: occupied ?? this.occupied,
      colorIndex: colorIndex ?? this.colorIndex,
      clearing: clearing ?? this.clearing,
    );
  }

  BlockColorSet? get colorSet =>
      occupied ? AppColors.blockColors[colorIndex % AppColors.blockColors.length] : null;
}
