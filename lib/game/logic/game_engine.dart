import 'package:flutter/foundation.dart';
import '../models/block.dart';
import '../models/game_state.dart';
import 'collision_detector.dart';
import 'piece_generator.dart';
import 'scoring_system.dart';
import '../../utils/constants.dart';

/// Placement result for UI to animate.
class PlacementResult {
  final int placementPoints;
  final int clearPoints;
  final int linesCleared;
  final int combo;
  final Set<BlockCell> clearedCells;
  final bool isNewHighScore;

  const PlacementResult({
    required this.placementPoints,
    required this.clearPoints,
    required this.linesCleared,
    required this.combo,
    required this.clearedCells,
    required this.isNewHighScore,
  });
}

/// Central game engine that manages all game state.
class GameEngine extends ChangeNotifier {
  late List<List<BoardCell>> _board;
  late List<GamePiece> _currentPieces;
  late GameState _state;
  late ScoringSystem _scoring;
  late PieceGenerator _pieceGenerator;

  // Drag state
  int? _dragPieceIndex;
  int? _previewRow;
  int? _previewCol;
  bool _previewValid = false;

  GameEngine() {
    _scoring = ScoringSystem();
    _pieceGenerator = PieceGenerator();
    _initBoard();
    _state = GameState.idle;
    _currentPieces = [];
  }

  // Getters
  List<List<BoardCell>> get board => _board;
  List<GamePiece> get currentPieces => _currentPieces;
  GameState get state => _state;
  int get score => _scoring.score;
  int get highScore => _scoring.highScore;
  int get combo => _scoring.combo;
  bool get isNewHighScore => _scoring.isNewHighScore;
  int? get dragPieceIndex => _dragPieceIndex;
  int? get previewRow => _previewRow;
  int? get previewCol => _previewCol;
  bool get previewValid => _previewValid;

  /// Set saved high score from storage.
  void setHighScore(int saved) {
    _scoring.setHighScore(saved);
    notifyListeners();
  }

  /// Initialize an empty board.
  void _initBoard() {
    _board = List.generate(
      AppConstants.gridSize,
      (_) => List.generate(AppConstants.gridSize, (_) => const BoardCell()),
    );
  }

  /// Start a new game.
  void startGame() {
    _initBoard();
    _scoring.reset();
    _state = GameState.playing;
    _currentPieces = _pieceGenerator.generatePieces(_board, _scoring.score);
    _dragPieceIndex = null;
    _previewRow = null;
    _previewCol = null;
    notifyListeners();
  }

  /// Restart the game.
  void restart() {
    startGame();
  }

  /// Pause the game.
  void pause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      notifyListeners();
    }
  }

  /// Resume the game.
  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      notifyListeners();
    }
  }

  // === Drag & Drop ===

  /// Begin dragging a piece.
  void startDrag(int pieceIndex) {
    if (_state != GameState.playing) return;
    if (pieceIndex < 0 || pieceIndex >= _currentPieces.length) return;
    if (_currentPieces[pieceIndex].isPlaced) return;

    _dragPieceIndex = pieceIndex;
    _state = GameState.dragging;
    notifyListeners();
  }

  /// Update drag preview position.
  void updateDragPreview(int? boardRow, int? boardCol) {
    if (_dragPieceIndex == null) return;
    // Allow updates in both dragging state
    if (_state != GameState.dragging) return;

    final oldRow = _previewRow;
    final oldCol = _previewCol;
    final oldValid = _previewValid;

    _previewRow = boardRow;
    _previewCol = boardCol;

    if (boardRow != null && boardCol != null) {
      _previewValid = CollisionDetector.canPlace(
        _board,
        _currentPieces[_dragPieceIndex!].shape,
        boardRow,
        boardCol,
      );
    } else {
      _previewValid = false;
    }

    // Only notify if something actually changed to reduce rebuilds
    if (oldRow != _previewRow || oldCol != _previewCol || oldValid != _previewValid) {
      notifyListeners();
    }
  }

  /// Drop the piece. Returns PlacementResult if placed, null if invalid.
  PlacementResult? dropPiece() {
    if (_dragPieceIndex == null) return null;
    // Accept drop from dragging state
    if (_state != GameState.dragging) return null;

    PlacementResult? result;

    if (_previewRow != null && _previewCol != null && _previewValid) {
      result = _placePiece(_dragPieceIndex!, _previewRow!, _previewCol!);
    }

    _dragPieceIndex = null;
    _previewRow = null;
    _previewCol = null;
    _previewValid = false;

    if (result == null) {
      _state = GameState.playing;
    }
    // If result != null, state is set to placing in _placePiece

    notifyListeners();
    return result;
  }

  /// Cancel a drag.
  void cancelDrag() {
    _dragPieceIndex = null;
    _previewRow = null;
    _previewCol = null;
    _previewValid = false;
    if (_state == GameState.dragging) {
      _state = GameState.playing;
    }
    notifyListeners();
  }

  // === Placement Logic ===

  PlacementResult? _placePiece(int pieceIndex, int startRow, int startCol) {
    final piece = _currentPieces[pieceIndex];

    if (!CollisionDetector.canPlace(_board, piece.shape, startRow, startCol)) {
      return null;
    }

    // Place the piece on the board
    _state = GameState.placing;
    for (final cell in piece.shape.cells) {
      final row = startRow + cell.row;
      final col = startCol + cell.col;
      _board[row][col] = BoardCell(
        occupied: true,
        colorIndex: piece.colorIndex,
      );
    }

    // Mark piece as placed
    _currentPieces[pieceIndex] = piece.copyWith(isPlaced: true);

    // Score placement
    final placementPoints = _scoring.scorePlacement(piece.shape.cellCount);

    // Check for line clears
    final cellsToClear = CollisionDetector.getCellsToClear(_board);
    final fullRows = CollisionDetector.findFullRows(_board);
    final fullCols = CollisionDetector.findFullCols(_board);
    final linesCleared = fullRows.length + fullCols.length;

    int clearPoints = 0;
    if (linesCleared > 0) {
      clearPoints = _scoring.scoreClear(linesCleared);

      // Mark cells as clearing
      for (final cell in cellsToClear) {
        _board[cell.row][cell.col] = _board[cell.row][cell.col].copyWith(clearing: true);
      }
    } else {
      _scoring.resetCombo();
    }

    final wasNewHighScore = _scoring.isNewHighScore;

    return PlacementResult(
      placementPoints: placementPoints,
      clearPoints: clearPoints,
      linesCleared: linesCleared,
      combo: _scoring.combo,
      clearedCells: cellsToClear,
      isNewHighScore: wasNewHighScore,
    );
  }

  /// Execute the clearing of marked cells. Call this after the clearing animation.
  void executeClear() {
    for (int row = 0; row < AppConstants.gridSize; row++) {
      for (int col = 0; col < AppConstants.gridSize; col++) {
        if (_board[row][col].clearing) {
          _board[row][col] = const BoardCell();
        }
      }
    }

    _checkPieceRefreshOrGameOver();
    notifyListeners();
  }

  /// Finalize placement (after animation). Returns true if game continues.
  void finalizePlacement() {
    _checkPieceRefreshOrGameOver();
    notifyListeners();
  }

  void _checkPieceRefreshOrGameOver() {
    // Check if all pieces are placed
    final allPlaced = _currentPieces.every((p) => p.isPlaced);
    if (allPlaced) {
      // Generate new pieces
      _currentPieces = _pieceGenerator.generatePieces(_board, _scoring.score);
    }

    // Check game over - can any remaining piece be placed?
    final remainingPieces = _currentPieces.where((p) => !p.isPlaced).toList();
    if (!CollisionDetector.canPlaceAny(_board, remainingPieces)) {
      _state = GameState.gameOver;
    } else {
      _state = GameState.playing;
    }
  }

  /// Check if a specific piece can fit anywhere.
  bool canPieceFit(int pieceIndex) {
    if (pieceIndex >= _currentPieces.length) return false;
    final piece = _currentPieces[pieceIndex];
    if (piece.isPlaced) return false;
    return CollisionDetector.canPlaceAnywhere(_board, piece.shape);
  }
}
