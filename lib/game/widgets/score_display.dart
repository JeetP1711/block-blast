import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Animated score display with counting animation.
class ScoreDisplay extends StatefulWidget {
  final int score;
  final int highScore;
  final String? bonusText; // format: "points_uniqueId"
  final int? comboCount;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.highScore,
    this.bonusText,
    this.comboCount,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;
  int _displayedScore = 0;

  // Bonus popup
  AnimationController? _bonusController;
  Animation<double>? _bonusOpacity;
  Animation<Offset>? _bonusSlide;
  Animation<double>? _bonusScale;
  String _lastBonusKey = '';
  String _bonusDisplayText = '';

  // Combo popup
  AnimationController? _comboController;
  Animation<double>? _comboOpacity;
  Animation<double>? _comboScale;
  int _displayedCombo = 0;

  @override
  void initState() {
    super.initState();
    _displayedScore = widget.score;
    _scoreController = AnimationController(
      duration: AppConstants.scoreDuration,
      vsync: this,
    );
    _scoreAnimation =
        IntTween(begin: _displayedScore, end: _displayedScore).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate score change
    if (widget.score != _displayedScore) {
      _scoreAnimation =
          IntTween(begin: _displayedScore, end: widget.score).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOut),
      );
      _scoreController.forward(from: 0);
      _scoreController.addStatusListener(_onScoreAnimDone);
    }

    // Show bonus popup (unique key check)
    if (widget.bonusText != null && widget.bonusText != _lastBonusKey) {
      _lastBonusKey = widget.bonusText!;
      // Parse the points from "points_uniqueId" format
      final parts = widget.bonusText!.split('_');
      _bonusDisplayText = parts.first;
      _showBonusPopup();
    }

    // Show combo popup
    if (widget.comboCount != null &&
        widget.comboCount! > 1 &&
        widget.comboCount != oldWidget.comboCount) {
      _displayedCombo = widget.comboCount!;
      _showComboPopup();
    }
  }

  void _onScoreAnimDone(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _displayedScore = widget.score;
    }
  }

  void _showBonusPopup() {
    _bonusController?.dispose();
    _bonusController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bonusOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_bonusController!);
    _bonusSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(
      parent: _bonusController!,
      curve: Curves.easeOut,
    ));
    _bonusScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 60),
    ]).animate(_bonusController!);

    _bonusController!.forward();
    if (mounted) setState(() {});
  }

  void _showComboPopup() {
    _comboController?.dispose();
    _comboController = AnimationController(
      duration: AppConstants.comboDuration,
      vsync: this,
    );
    _comboOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_comboController!);
    _comboScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.95), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 55),
    ]).animate(_comboController!);

    _comboController!.forward();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scoreController.removeStatusListener(_onScoreAnimDone);
    _scoreController.dispose();
    _bonusController?.dispose();
    _comboController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // High Score
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.textAccent, size: 16),
            const SizedBox(width: 4),
            Text(
              'BEST  ${Helpers.formatScore(widget.highScore)}',
              style: AppTextStyles.scoreLabel.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Score Label
        Text(
          'SCORE',
          style: AppTextStyles.scoreLabel,
        ),
        const SizedBox(height: 2),
        // Animated Score
        AnimatedBuilder(
          animation: _scoreController,
          builder: (context, child) {
            return Text(
              Helpers.formatScore(_scoreAnimation.value),
              style: AppTextStyles.score,
            );
          },
        ),
        // Bonus popup
        SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_bonusController != null && _bonusOpacity != null)
                AnimatedBuilder(
                  animation: _bonusController!,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _bonusSlide!,
                      child: Opacity(
                        opacity: _bonusOpacity!.value,
                        child: Transform.scale(
                          scale: _bonusScale!.value,
                          child: Text(
                            '+$_bonusDisplayText',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textAccent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (_comboController != null && _comboOpacity != null)
                AnimatedBuilder(
                  animation: _comboController!,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _comboOpacity!.value,
                      child: Transform.scale(
                        scale: _comboScale!.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.textAccent.withValues(alpha: 0.2),
                                AppColors.buttonGlow.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'COMBO x$_displayedCombo!',
                            style: AppTextStyles.combo.copyWith(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
