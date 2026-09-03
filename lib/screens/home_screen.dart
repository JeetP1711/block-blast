import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';

/// Home screen with animated floating blocks background.
class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final HapticService hapticService;
  final SoundService soundService;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.hapticService,
    required this.soundService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _titleController;
  late Animation<double> _titleScale;
  late Animation<double> _titleOpacity;
  final List<_FloatingBlock> _floatingBlocks = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Background animation
    _bgController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _titleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.05), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    ));
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0, 0.5),
      ),
    );

    // Generate floating blocks
    for (int i = 0; i < 15; i++) {
      _floatingBlocks.add(_FloatingBlock(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 30,
        speed: 0.3 + _random.nextDouble() * 0.7,
        colorIndex: _random.nextInt(AppColors.blockColors.length),
        opacity: 0.08 + _random.nextDouble() * 0.12,
        phase: _random.nextDouble() * 2 * pi,
      ));
    }

    _titleController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highScore = widget.storageService.getHighScore();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating blocks background
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _FloatingBlocksPainter(
                      blocks: _floatingBlocks,
                      progress: _bgController.value,
                    ),
                  );
                },
              ),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleOpacity.value,
                      child: Transform.scale(
                        scale: _titleScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // Game title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF6C5CE7),
                            Color(0xFFA29BFE),
                            Color(0xFF48DBAB),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'BLOCK',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 56,
                            height: 1.0,
                          ),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFECA57),
                            Color(0xFFFF9F43),
                            Color(0xFFFF6B6B),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'BURST',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 56,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // High Score
                      if (highScore > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.buttonBg.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.gridBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                color: AppColors.textAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'BEST  ${Helpers.formatScore(highScore)}',
                                style: AppTextStyles.scoreLabel.copyWith(
                                  fontSize: 14,
                                  color: AppColors.textAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                      ] else
                        const SizedBox(height: 48),

                      // Play Button
                      _HomeButton(
                        label: 'PLAY',
                        icon: Icons.play_arrow_rounded,
                        gradient: const [Color(0xFF6C5CE7), Color(0xFF8E80EF)],
                        glowColor: AppColors.buttonGlow,
                        onPressed: () {
                          widget.hapticService.mediumImpact();
                          widget.soundService.playButtonClick();
                          Navigator.pushNamed(context, '/game');
                        },
                      ),
                      const SizedBox(height: 16),

                      // Settings button
                      _HomeButton(
                        label: 'SETTINGS',
                        icon: Icons.settings_rounded,
                        gradient: const [Color(0xFF1E2548), Color(0xFF2A3365)],
                        glowColor: Colors.transparent,
                        onPressed: () {
                          widget.hapticService.lightImpact();
                          widget.soundService.playButtonClick();
                          Navigator.pushNamed(context, '/settings');
                        },
                        small: true,
                      ),
                      const SizedBox(height: 12),

                      // How to play
                      _HomeButton(
                        label: 'HOW TO PLAY',
                        icon: Icons.help_outline_rounded,
                        gradient: const [Color(0xFF1E2548), Color(0xFF2A3365)],
                        glowColor: Colors.transparent,
                        onPressed: () {
                          widget.hapticService.lightImpact();
                          widget.soundService.playButtonClick();
                          Navigator.pushNamed(context, '/tutorial');
                        },
                        small: true,
                      ),

                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onPressed;
  final bool small;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onPressed,
    this.small = false,
  });

  @override
  State<_HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<_HomeButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
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
              width: widget.small ? 220 : 240,
              padding: EdgeInsets.symmetric(
                vertical: widget.small ? 14 : 18,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.gradient),
                borderRadius: BorderRadius.circular(16),
                border: widget.small
                    ? Border.all(color: AppColors.gridBorder, width: 1)
                    : null,
                boxShadow: widget.glowColor != Colors.transparent
                    ? [
                        BoxShadow(
                          color: widget.glowColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: widget.small ? 20 : 24),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: AppTextStyles.button.copyWith(
                      fontSize: widget.small ? 14 : 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// === Floating Blocks Background ===

class _FloatingBlock {
  final double x, y, size, speed, opacity, phase;
  final int colorIndex;

  _FloatingBlock({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.colorIndex,
    required this.opacity,
    required this.phase,
  });
}

class _FloatingBlocksPainter extends CustomPainter {
  final List<_FloatingBlock> blocks;
  final double progress;

  _FloatingBlocksPainter({required this.blocks, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final block in blocks) {
      final t = (progress * block.speed + block.phase) % 1.0;
      final bx = block.x * size.width + sin(t * 2 * pi) * 30;
      final by = (block.y + t * 0.5) % 1.2 * size.height - size.height * 0.1;

      final paint = Paint()
        ..color = AppColors.blockColors[block.colorIndex].main
            .withValues(alpha: block.opacity)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(bx, by),
          width: block.size,
          height: block.size,
        ),
        Radius.circular(block.size * 0.2),
      );

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingBlocksPainter oldDelegate) => true;
}
