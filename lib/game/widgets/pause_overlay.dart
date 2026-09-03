import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Pause overlay with resume, restart, and settings options.
class PauseOverlay extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgOpacity;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onResume,
                child: Opacity(
                  opacity: _bgOpacity.value,
                  child: Container(color: AppColors.overlayBg),
                ),
              ),
            ),
            Center(
              child: Transform.scale(
                scale: _cardScale.value,
                child: Opacity(
                  opacity: _bgOpacity.value,
                  child: _buildCard(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2042), Color(0xFF0D1225)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gridBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonGlow.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PAUSED',
            style: AppTextStyles.title.copyWith(
              fontSize: 28,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 32),
          _PauseButton(
            label: 'RESUME',
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF48DBAB),
            onPressed: widget.onResume,
          ),
          const SizedBox(height: 12),
          _PauseButton(
            label: 'RESTART',
            icon: Icons.refresh_rounded,
            color: const Color(0xFFFF9F43),
            onPressed: widget.onRestart,
          ),
          const SizedBox(height: 12),
          _PauseButton(
            label: 'SETTINGS',
            icon: Icons.settings_rounded,
            color: const Color(0xFF6C5CE7),
            onPressed: widget.onSettings,
          ),
        ],
      ),
    );
  }
}

class _PauseButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _PauseButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton>
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: widget.color, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: AppTextStyles.button.copyWith(
                      color: widget.color,
                      fontSize: 16,
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
