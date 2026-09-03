import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/game_state.dart';
import '../logic/game_engine.dart';
import 'block_widget.dart';
import '../../utils/constants.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';

/// The piece tray and drag handler.
class PieceTray extends StatefulWidget {
  final GameEngine engine;
  final double boardSize;
  final GlobalKey boardKey;
  final HapticService hapticService;
  final SoundService soundService;
  final VoidCallback onPiecePlaced;

  const PieceTray({
    super.key,
    required this.engine,
    required this.boardSize,
    required this.boardKey,
    required this.hapticService,
    required this.soundService,
    required this.onPiecePlaced,
  });

  @override
  State<PieceTray> createState() => _PieceTrayState();
}

class _PieceTrayState extends State<PieceTray> with TickerProviderStateMixin {
  int? _draggingIndex;
  Offset _dragPosition = Offset.zero;
  late double _cellSize;
  late double _trayCellSize;
  late double _boardPadding;

  GameEngine get engine => widget.engine;

  @override
  Widget build(BuildContext context) {
    _boardPadding = 8.0;
    final innerBoardSize = widget.boardSize - _boardPadding * 2;
    _cellSize = (innerBoardSize - (AppConstants.gridSize - 1) * AppConstants.gridSpacing) /
        AppConstants.gridSize;
    _trayCellSize = _cellSize * AppConstants.pieceTrayScale;

    final pieces = engine.currentPieces;
    if (pieces.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(pieces.length, (index) {
              final piece = pieces[index];
              if (piece.isPlaced || _draggingIndex == index) {
                return _emptySlot(piece);
              }
              return _buildDraggablePiece(piece, index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _emptySlot(GamePiece piece) {
    return SizedBox(
      width: piece.shape.width * (_trayCellSize + AppConstants.gridSpacing) + 16,
      height: piece.shape.height * (_trayCellSize + AppConstants.gridSpacing) + 16,
    );
  }

  Widget _buildDraggablePiece(GamePiece piece, int index) {
    final canFit = engine.canPieceFit(index);

    return GestureDetector(
      onPanStart: (details) {
        if (engine.state != GameState.playing) return;
        setState(() {
          _draggingIndex = index;
          _dragPosition = details.globalPosition;
        });
        engine.startDrag(index);
        widget.hapticService.lightImpact();
        widget.soundService.playPickup();
      },
      onPanUpdate: (details) {
        if (_draggingIndex != index) return;
        setState(() {
          _dragPosition = details.globalPosition;
        });
        _updateBoardPreview(piece);
      },
      onPanEnd: (details) {
        if (_draggingIndex != index) return;
        _handleDrop();
      },
      onPanCancel: () {
        if (_draggingIndex != index) return;
        engine.cancelDrag();
        setState(() {
          _draggingIndex = null;
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: canFit ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: _buildPieceGrid(piece, _trayCellSize),
        ),
      ),
    );
  }

  void _updateBoardPreview(GamePiece piece) {
    final boardBox =
        widget.boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (boardBox == null) return;

    final boardPos = boardBox.localToGlobal(Offset.zero);
    final cellTotal = _cellSize + AppConstants.gridSpacing;

    // Calculate which cell the center of the piece would land on
    // Offset upward so the piece appears above the finger
    final fingerOffset = _cellSize * piece.shape.height * 0.5 + 60;
    final localX = _dragPosition.dx - boardPos.dx - _boardPadding;
    final localY = _dragPosition.dy - boardPos.dy - _boardPadding - fingerOffset;

    // Center the piece on the finger
    final adjustedX = localX - (piece.shape.width * cellTotal) / 2 + cellTotal / 2;
    final adjustedY = localY - (piece.shape.height * cellTotal) / 2 + cellTotal / 2;

    final col = (adjustedX / cellTotal).round();
    final row = (adjustedY / cellTotal).round();

    if (row >= 0 && row < AppConstants.gridSize && col >= 0 && col < AppConstants.gridSize) {
      engine.updateDragPreview(row, col);
    } else {
      engine.updateDragPreview(null, null);
    }
  }

  void _handleDrop() {
    final result = engine.dropPiece();
    if (result != null) {
      widget.hapticService.mediumImpact();
      widget.soundService.playPlace();
      widget.onPiecePlaced();

      if (result.linesCleared > 0) {
        Future.delayed(const Duration(milliseconds: 50), () {
          widget.hapticService.heavyImpact();
          widget.soundService.playClear();
          if (result.combo > 1) {
            widget.soundService.playCombo();
          }

          // Execute clearing after animation
          Future.delayed(AppConstants.clearDuration, () {
            engine.executeClear();
          });
        });
      } else {
        engine.finalizePlacement();
      }
    } else {
      widget.soundService.playInvalid();
    }
    setState(() {
      _draggingIndex = null;
    });
  }

  Widget _buildPieceGrid(GamePiece piece, double cellSize) {
    return SizedBox(
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
    );
  }
}
