import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';

/// Settings screen with toggles and theme options.
class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final HapticService hapticService;
  final SoundService soundService;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.hapticService,
    required this.soundService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _hapticEnabled;
  late bool _animationsEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.storageService.getSoundEnabled();
    _musicEnabled = widget.storageService.getMusicEnabled();
    _hapticEnabled = widget.storageService.getHapticEnabled();
    _animationsEnabled = widget.storageService.getAnimationsEnabled();
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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'SETTINGS',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 24,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _SettingCard(
                      icon: Icons.volume_up_rounded,
                      label: 'Sound Effects',
                      value: _soundEnabled,
                      onChanged: (v) {
                        setState(() => _soundEnabled = v);
                        widget.storageService.setSoundEnabled(v);
                        widget.soundService.setSoundEnabled(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingCard(
                      icon: Icons.music_note_rounded,
                      label: 'Music',
                      value: _musicEnabled,
                      onChanged: (v) {
                        setState(() => _musicEnabled = v);
                        widget.storageService.setMusicEnabled(v);
                        widget.soundService.setMusicEnabled(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingCard(
                      icon: Icons.vibration_rounded,
                      label: 'Haptic Feedback',
                      value: _hapticEnabled,
                      onChanged: (v) {
                        setState(() => _hapticEnabled = v);
                        widget.storageService.setHapticEnabled(v);
                        widget.hapticService.setEnabled(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingCard(
                      icon: Icons.animation_rounded,
                      label: 'Animations',
                      value: _animationsEnabled,
                      onChanged: (v) {
                        setState(() => _animationsEnabled = v);
                        widget.storageService.setAnimationsEnabled(v);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Reset High Score
                    GestureDetector(
                      onTap: () => _showResetDialog(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFFF6B6B),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Reset Best Score',
                              style: AppTextStyles.body.copyWith(
                                color: const Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Best Score?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will permanently delete your best score.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.storageService.resetHighScore();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Best score reset!'),
                  backgroundColor: AppColors.bgLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.buttonBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gridBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C5CE7),
            activeTrackColor: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.buttonBg,
          ),
        ],
      ),
    );
  }
}
