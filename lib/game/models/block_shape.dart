import 'block.dart';

/// All block shape definitions.
class BlockShapes {
  // Single
  static const single = BlockShape(
    name: 'single',
    cells: [BlockCell(0, 0)],
  );

  // Horizontal lines
  static const line2H = BlockShape(
    name: 'line2H',
    cells: [BlockCell(0, 0), BlockCell(0, 1)],
  );

  static const line3H = BlockShape(
    name: 'line3H',
    cells: [BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2)],
  );

  static const line4H = BlockShape(
    name: 'line4H',
    cells: [BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2), BlockCell(0, 3)],
  );

  static const line5H = BlockShape(
    name: 'line5H',
    cells: [BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2), BlockCell(0, 3), BlockCell(0, 4)],
  );

  // Vertical lines
  static const line2V = BlockShape(
    name: 'line2V',
    cells: [BlockCell(0, 0), BlockCell(1, 0)],
  );

  static const line3V = BlockShape(
    name: 'line3V',
    cells: [BlockCell(0, 0), BlockCell(1, 0), BlockCell(2, 0)],
  );

  static const line4V = BlockShape(
    name: 'line4V',
    cells: [BlockCell(0, 0), BlockCell(1, 0), BlockCell(2, 0), BlockCell(3, 0)],
  );

  static const line5V = BlockShape(
    name: 'line5V',
    cells: [BlockCell(0, 0), BlockCell(1, 0), BlockCell(2, 0), BlockCell(3, 0), BlockCell(4, 0)],
  );

  // Squares
  static const square2 = BlockShape(
    name: 'square2',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1),
      BlockCell(1, 0), BlockCell(1, 1),
    ],
  );

  static const square3 = BlockShape(
    name: 'square3',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 0), BlockCell(1, 1), BlockCell(1, 2),
      BlockCell(2, 0), BlockCell(2, 1), BlockCell(2, 2),
    ],
  );

  // L shapes
  static const lShape = BlockShape(
    name: 'lShape',
    cells: [
      BlockCell(0, 0),
      BlockCell(1, 0),
      BlockCell(2, 0), BlockCell(2, 1),
    ],
  );

  static const lShapeR = BlockShape(
    name: 'lShapeR',
    cells: [
      BlockCell(0, 1),
      BlockCell(1, 1),
      BlockCell(2, 0), BlockCell(2, 1),
    ],
  );

  static const lShape90 = BlockShape(
    name: 'lShape90',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 0),
    ],
  );

  static const lShape180 = BlockShape(
    name: 'lShape180',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1),
      BlockCell(1, 1),
      BlockCell(2, 1),
    ],
  );

  static const lShape270 = BlockShape(
    name: 'lShape270',
    cells: [
      BlockCell(0, 2),
      BlockCell(1, 0), BlockCell(1, 1), BlockCell(1, 2),
    ],
  );

  static const lShapeR90 = BlockShape(
    name: 'lShapeR90',
    cells: [
      BlockCell(0, 0),
      BlockCell(1, 0), BlockCell(1, 1), BlockCell(1, 2),
    ],
  );

  static const lShapeR180 = BlockShape(
    name: 'lShapeR180',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1),
      BlockCell(1, 0),
      BlockCell(2, 0),
    ],
  );

  static const lShapeR270 = BlockShape(
    name: 'lShapeR270',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 2),
    ],
  );

  // T shapes
  static const tShape = BlockShape(
    name: 'tShape',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 1),
    ],
  );

  static const tShape90 = BlockShape(
    name: 'tShape90',
    cells: [
      BlockCell(0, 0),
      BlockCell(1, 0), BlockCell(1, 1),
      BlockCell(2, 0),
    ],
  );

  static const tShape180 = BlockShape(
    name: 'tShape180',
    cells: [
      BlockCell(0, 1),
      BlockCell(1, 0), BlockCell(1, 1), BlockCell(1, 2),
    ],
  );

  static const tShape270 = BlockShape(
    name: 'tShape270',
    cells: [
      BlockCell(0, 1),
      BlockCell(1, 0), BlockCell(1, 1),
      BlockCell(2, 1),
    ],
  );

  // Z / S shapes
  static const zShape = BlockShape(
    name: 'zShape',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1),
      BlockCell(1, 1), BlockCell(1, 2),
    ],
  );

  static const zShapeV = BlockShape(
    name: 'zShapeV',
    cells: [
      BlockCell(0, 1),
      BlockCell(1, 0), BlockCell(1, 1),
      BlockCell(2, 0),
    ],
  );

  static const sShape = BlockShape(
    name: 'sShape',
    cells: [
      BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 0), BlockCell(1, 1),
    ],
  );

  static const sShapeV = BlockShape(
    name: 'sShapeV',
    cells: [
      BlockCell(0, 0),
      BlockCell(1, 0), BlockCell(1, 1),
      BlockCell(2, 1),
    ],
  );

  // Plus
  static const plus = BlockShape(
    name: 'plus',
    cells: [
      BlockCell(0, 1),
      BlockCell(1, 0), BlockCell(1, 1), BlockCell(1, 2),
      BlockCell(2, 1),
    ],
  );

  // Corner shapes (2x2 minus 1)
  static const cornerTL = BlockShape(
    name: 'cornerTL',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1),
      BlockCell(1, 0),
    ],
  );

  static const cornerTR = BlockShape(
    name: 'cornerTR',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1),
      BlockCell(1, 1),
    ],
  );

  static const cornerBL = BlockShape(
    name: 'cornerBL',
    cells: [
      BlockCell(0, 0),
      BlockCell(1, 0), BlockCell(1, 1),
    ],
  );

  static const cornerBR = BlockShape(
    name: 'cornerBR',
    cells: [
      BlockCell(0, 1),
      BlockCell(1, 0), BlockCell(1, 1),
    ],
  );

  // Big L shapes (3x3 corner)
  static const bigCornerTL = BlockShape(
    name: 'bigCornerTL',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 0),
      BlockCell(2, 0),
    ],
  );

  static const bigCornerTR = BlockShape(
    name: 'bigCornerTR',
    cells: [
      BlockCell(0, 0), BlockCell(0, 1), BlockCell(0, 2),
      BlockCell(1, 2),
      BlockCell(2, 2),
    ],
  );

  static const bigCornerBL = BlockShape(
    name: 'bigCornerBL',
    cells: [
      BlockCell(0, 0),
      BlockCell(1, 0),
      BlockCell(2, 0), BlockCell(2, 1), BlockCell(2, 2),
    ],
  );

  static const bigCornerBR = BlockShape(
    name: 'bigCornerBR',
    cells: [
      BlockCell(0, 2),
      BlockCell(1, 2),
      BlockCell(2, 0), BlockCell(2, 1), BlockCell(2, 2),
    ],
  );

  /// All shapes grouped by difficulty tier.
  static const List<BlockShape> easyShapes = [
    single,
    line2H, line2V,
    line3H, line3V,
    square2,
    cornerTL, cornerTR, cornerBL, cornerBR,
  ];

  static const List<BlockShape> mediumShapes = [
    line4H, line4V,
    lShape, lShapeR, lShape90, lShape180, lShape270,
    lShapeR90, lShapeR180, lShapeR270,
    tShape, tShape90, tShape180, tShape270,
    zShape, zShapeV, sShape, sShapeV,
  ];

  static const List<BlockShape> hardShapes = [
    line5H, line5V,
    square3,
    plus,
    bigCornerTL, bigCornerTR, bigCornerBL, bigCornerBR,
  ];

  static const List<BlockShape> allShapes = [
    ...easyShapes,
    ...mediumShapes,
    ...hardShapes,
  ];
}
