import 'package:flutter/material.dart';
import '../game/models/game_state.dart';
import '../game/logic/game_engine.dart';
import '../game/widgets/game_board_widget.dart';
import '../game/widgets/piece_tray.dart';
import '../game/widgets/score_display.dart';
import '../game/widgets/game_over_overlay.dart';
import '../game/widgets/pause_overlay.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  final StorageService storageService;
  final HapticService hapticService;
  final SoundService soundService;

  const GameScreen({
    super.key,
    required this.storageService,
    required this.hapticService,
    required this.soundService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine _engine;
  final GlobalKey _boardKey = GlobalKey();

  // Score animation state
  String? _bonusText;
  int? _comboCount;
  int _bonusCounter = 0; // unique id so duplicate values still trigger animation

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _engine.setHighScore(widget.storageService.getHighScore());
    _engine.addListener(_onEngineChanged);
    _engine.startGame();
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    _engine.dispose();
    super.dispose();
  }

  void _onEngineChanged() {
    if (!mounted) return;
    
    // Only do a full screen rebuild for major state changes,
    // not for drag preview updates (the board handles those itself)
    final state = _engine.state;
    if (state == GameState.dragging) {
      // Board handles its own preview rendering via ListenableBuilder
      // Don't need to rebuild the whole screen for drag updates
      return;
    }
    
    setState(() {});

    if (state == GameState.gameOver) {
      widget.hapticService.heavyImpact();
      widget.soundService.playGameOver();
      widget.storageService.setHighScore(_engine.highScore);
      if (_engine.isNewHighScore) {
        widget.soundService.playNewHighScore();
      }
    }
  }

  void _onPiecePlaced(PlacementResult result) {
    _bonusCounter++;
    setState(() {
      final totalPoints = result.placementPoints + result.clearPoints;
      _bonusText = '${totalPoints}_$_bonusCounter'; // unique key
      if (result.combo > 1) {
        _comboCount = result.combo;
      }
    });

    widget.storageService.setHighScore(_engine.highScore);

    if (result.linesCleared > 0) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        widget.hapticService.heavyImpact();
        widget.soundService.playClear();
        if (result.combo > 1) {
          widget.soundService.playCombo();
        }
        // Execute clearing after animation
        Future.delayed(AppConstants.clearDuration, () {
          if (!mounted) return;
          _engine.executeClear();
        });
      });
    } else {
      _engine.finalizePlacement();
    }
  }

  void _handlePlayAgain() {
    widget.hapticService.lightImpact();
    widget.soundService.playButtonClick();
    setState(() {
      _bonusText = null;
      _comboCount = null;
    });
    _engine.restart();
  }

  void _handlePause() {
    widget.hapticService.lightImpact();
    widget.soundService.playButtonClick();
    _engine.pause();
  }

  void _handleResume() {
    widget.hapticService.lightImpact();
    _engine.resume();
  }

  void _handleRestart() {
    widget.hapticService.lightImpact();
    widget.soundService.playButtonClick();
    setState(() {
      _bonusText = null;
      _comboCount = null;
    });
    _engine.restart();
  }

  void _handleSettings() {
    widget.hapticService.lightImpact();
    _engine.resume();
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDark],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBoardSize = constraints.maxWidth - 24;
              final boardSize = maxBoardSize.clamp(0.0, 400.0);

              return Stack(
                children: [
                  // Main game content
                  Column(
                    children: [
                      // Top bar
                      _buildTopBar(),
                      const SizedBox(height: 8),
                      // Score — uses ListenableBuilder for real-time score updates
                      ListenableBuilder(
                        listenable: _engine,
                        builder: (context, _) {
                          return ScoreDisplay(
                            score: _engine.score,
                            highScore: _engine.highScore,
                            bonusText: _bonusText,
                            comboCount: _comboCount,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Board — uses ListenableBuilder internally for preview updates
                      Center(
                        child: Container(
                          key: _boardKey,
                          child: GameBoardWidget(
                            engine: _engine,
                            boardSize: boardSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Instruction
                      Text(
                        'Drag a block onto the board',
                        style: AppTextStyles.instruction,
                      ),
                      const SizedBox(height: 8),
                      // Piece tray
                      Expanded(
                        child: Center(
                          child: PieceTray(
                            engine: _engine,
                            boardSize: boardSize,
                            boardKey: _boardKey,
                            hapticService: widget.hapticService,
                            soundService: widget.soundService,
                            onPiecePlaced: _onPiecePlaced,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  // Pause overlay
                  if (_engine.state == GameState.paused)
                    Positioned.fill(
                      child: PauseOverlay(
                        onResume: _handleResume,
                        onRestart: _handleRestart,
                        onSettings: _handleSettings,
                      ),
                    ),

                  // Game over overlay
                  if (_engine.state == GameState.gameOver)
                    Positioned.fill(
                      child: GameOverOverlay(
                        score: _engine.score,
                        highScore: _engine.highScore,
                        isNewHighScore: _engine.isNewHighScore,
                        onPlayAgain: _handlePlayAgain,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause button
          _TopBarButton(
            icon: Icons.pause_rounded,
            onPressed: _handlePause,
          ),
          // Back to home
          _TopBarButton(
            icon: Icons.home_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _TopBarButton({required this.icon, required this.onPressed});

  @override
  State<_TopBarButton> createState() => _TopBarButtonState();
}

class _TopBarButtonState extends State<_TopBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.buttonPressDuration,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.buttonBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gridBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
