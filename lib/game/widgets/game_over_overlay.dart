import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Game Over overlay with score display, confetti, and play again button.
class GameOverOverlay extends StatefulWidget {
  final int score;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback onPlayAgain;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
    required this.onPlayAgain,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _cardController;
  late AnimationController _confettiController;
  late Animation<double> _bgOpacity;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;

  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOut),
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.05), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    if (widget.isNewHighScore) {
      _generateConfetti();
      _confettiController.repeat();
    }

    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardController.forward();
    });
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * -1,
        speed: 0.2 + _random.nextDouble() * 0.5,
        size: 4 + _random.nextDouble() * 8,
        color: AppColors.blockColors[_random.nextInt(AppColors.blockColors.length)].main,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: _random.nextDouble() * 4 - 2,
      ));
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bgController, _cardController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            Positioned.fill(
              child: Opacity(
                opacity: _bgOpacity.value,
                child: Container(
                  color: AppColors.overlayBg,
                ),
              ),
            ),

            // Confetti
            if (widget.isNewHighScore)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _confettiController.value,
                      ),
                    );
                  },
                ),
              ),

            // Card
            Center(
              child: Opacity(
                opacity: _cardOpacity.value,
                child: Transform.scale(
                  scale: _cardScale.value,
                  child: _buildCard(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A2042),
            Color(0xFF151B35),
            Color(0xFF0D1225),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gridBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonGlow.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GAME OVER',
            style: AppTextStyles.title.copyWith(
              fontSize: 32,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text('SCORE', style: AppTextStyles.scoreLabel),
          const SizedBox(height: 4),
          Text(
            Helpers.formatScore(widget.score),
            style: AppTextStyles.score.copyWith(fontSize: 42),
          ),
          const SizedBox(height: 16),
          if (widget.isNewHighScore) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.textAccent.withValues(alpha: 0.2),
                    AppColors.blockColors[3].main.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'NEW BEST!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textAccent,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.textAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  'BEST: ${Helpers.formatScore(widget.highScore)}',
                  style: AppTextStyles.scoreLabel,
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          _PlayAgainButton(onPressed: widget.onPlayAgain),
        ],
      ),
    );
  }
}

class _PlayAgainButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PlayAgainButton({required this.onPressed});

  @override
  State<_PlayAgainButton> createState() => _PlayAgainButtonState();
}

class _PlayAgainButtonState extends State<_PlayAgainButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8E80EF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonGlow.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text('PLAY AGAIN', style: AppTextStyles.button),
            ),
          );
        },
      ),
    );
  }
}

// === Confetti System ===

class _ConfettiParticle {
  double x, y, speed, size, rotation, rotationSpeed;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + progress * p.speed * 3) % 1.2 - 0.1;
      final currentX = p.x + sin(progress * pi * 2 * p.rotationSpeed) * 0.05;

      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - currentY).clamp(0.0, 0.8))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX * size.width, currentY * size.height);
      canvas.rotate((p.rotation + progress * p.rotationSpeed * 360) * pi / 180);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
