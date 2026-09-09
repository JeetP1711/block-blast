import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/game_state.dart';
import '../logic/game_engine.dart';
import 'block_widget.dart';
import '../../utils/constants.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';

/// Callback that receives placement result.
typedef PiecePlacedCallback = void Function(PlacementResult result);

/// The piece tray and drag handler.
class PieceTray extends StatefulWidget {
  final GameEngine engine;
  final double boardSize;
  final GlobalKey boardKey;
  final HapticService hapticService;
  final SoundService soundService;
  final PiecePlacedCallback onPiecePlaced;

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

  // Optimised smooth dragging offset notifier
  final ValueNotifier<Offset> _dragOverlayPosition = ValueNotifier(Offset.zero);

  // Overlay entry for floating dragged piece
  OverlayEntry? _dragOverlay;

  GameEngine get engine => widget.engine;

  @override
  void initState() {
    super.initState();
    engine.addListener(_onEngineChanged);
  }

  @override
  void dispose() {
    _removeDragOverlay();
    engine.removeListener(_onEngineChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(PieceTray oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.engine != widget.engine) {
      oldWidget.engine.removeListener(_onEngineChanged);
      widget.engine.addListener(_onEngineChanged);
    }
  }

  void _onEngineChanged() {
    // Only rebuild when NOT in the middle of a drag gesture to avoid
    // killing the GestureDetector. During drag, the overlay handles visuals.
    if (_draggingIndex == null && mounted) {
      setState(() {});
    }
  }

  void _removeDragOverlay() {
    _dragOverlay?.remove();
    _dragOverlay = null;
  }

  void _showDragOverlay(GamePiece piece) {
    _removeDragOverlay();
    
    // Set initial position
    _dragOverlayPosition.value = _dragPosition;

    _dragOverlay = OverlayEntry(
      builder: (context) {
        final pieceWidth = piece.shape.width * (_cellSize + AppConstants.gridSpacing);
        final pieceHeight = piece.shape.height * (_cellSize + AppConstants.gridSpacing);
        // Offset upward so piece appears above finger
        final fingerOffset = _cellSize * piece.shape.height * 0.5 + 60;

        return ValueListenableBuilder<Offset>(
          valueListenable: _dragOverlayPosition,
          builder: (context, pos, child) {
            return Positioned(
              left: pos.dx - pieceWidth / 2,
              top: pos.dy - pieceHeight / 2 - fingerOffset,
              child: child!,
            );
          },
          child: IgnorePointer(
            child: Transform.scale(
              scale: AppConstants.dragScale,
              child: Opacity(
                opacity: 0.85,
                child: Material(
                  color: Colors.transparent,
                  elevation: AppConstants.dragElevation,
                  shadowColor: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPieceGrid(piece, _cellSize),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_dragOverlay!);
  }

  void _updateDragOverlay() {
    // We no longer trigger a full rebuild of the overlay.
    // The ValueListenableBuilder automatically repaints the Positioned widget.
  }

  @override
  Widget build(BuildContext context) {
    _boardPadding = 8.0;
    final borderWidth = 1.5;
    final innerBoardSize = widget.boardSize - (_boardPadding * 2) - (borderWidth * 2);
    _cellSize = ((innerBoardSize - (AppConstants.gridSize - 1) * AppConstants.gridSpacing) /
        AppConstants.gridSize) - 0.001;
    _trayCellSize = _cellSize * AppConstants.pieceTrayScale;

    final pieces = engine.currentPieces;
    if (pieces.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(pieces.length, (index) {
          final piece = pieces[index];
          if (piece.isPlaced) {
            return _emptySlot(piece);
          }
          // CRITICAL FIX: Always build the GestureDetector even during drag,
          // but visually hide it. This prevents the gesture from being killed.
          return _buildDraggablePiece(piece, index);
        }),
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
    final isDragging = _draggingIndex == index;

    return GestureDetector(
      onPanStart: (details) {
        if (engine.state != GameState.playing) return;
        _draggingIndex = index;
        _dragPosition = details.globalPosition;
        engine.startDrag(index);
        widget.hapticService.lightImpact();
        widget.soundService.playPickup();
        _showDragOverlay(piece);
        setState(() {});
      },
      onPanUpdate: (details) {
        if (_draggingIndex != index) return;
        _dragPosition = details.globalPosition;
        _dragOverlayPosition.value = _dragPosition; // Fast position update
        _updateBoardPreview(piece);
      },
      onPanEnd: (details) {
        if (_draggingIndex != index) return;
        _handleDrop();
      },
      onPanCancel: () {
        if (_draggingIndex != index) return;
        _removeDragOverlay();
        _draggingIndex = null;
        engine.cancelDrag();
        setState(() {});
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDragging ? 0.0 : (canFit ? 1.0 : 0.4),
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

    // Offset upward so the piece appears above the finger
    final fingerOffset = _cellSize * piece.shape.height * 0.5 + 60;
    // Account for both padding and the container's border to align perfectly
    final boardOffset = _boardPadding + 1.5;
    final localX = _dragPosition.dx - boardPos.dx - boardOffset;
    final localY = _dragPosition.dy - boardPos.dy - boardOffset - fingerOffset;

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
    _removeDragOverlay();
    final result = engine.dropPiece();
    _draggingIndex = null;

    if (result != null) {
      widget.hapticService.mediumImpact();
      widget.soundService.playPlace();
      widget.onPiecePlaced(result);
    } else {
      widget.soundService.playInvalid();
    }
    // Force rebuild to show the piece back in the tray or mark as placed
    setState(() {});
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
