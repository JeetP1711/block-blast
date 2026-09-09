import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Handles local persistence for scores and settings.
class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // High Score
  int getHighScore() => _prefs?.getInt(AppConstants.highScoreKey) ?? 0;

  Future<void> setHighScore(int score) async {
    await _prefs?.setInt(AppConstants.highScoreKey, score);
  }

  Future<void> resetHighScore() async {
    await _prefs?.setInt(AppConstants.highScoreKey, 0);
  }

  // Sound
  bool getSoundEnabled() => _prefs?.getBool(AppConstants.soundEnabledKey) ?? true;

  Future<void> setSoundEnabled(bool value) async {
    await _prefs?.setBool(AppConstants.soundEnabledKey, value);
  }

  // Music
  bool getMusicEnabled() => _prefs?.getBool(AppConstants.musicEnabledKey) ?? true;

  Future<void> setMusicEnabled(bool value) async {
    await _prefs?.setBool(AppConstants.musicEnabledKey, value);
  }

  // Haptics
  bool getHapticEnabled() => _prefs?.getBool(AppConstants.hapticEnabledKey) ?? true;

  Future<void> setHapticEnabled(bool value) async {
    await _prefs?.setBool(AppConstants.hapticEnabledKey, value);
  }

  // Animations
  bool getAnimationsEnabled() => _prefs?.getBool(AppConstants.animationsEnabledKey) ?? true;

  Future<void> setAnimationsEnabled(bool value) async {
    await _prefs?.setBool(AppConstants.animationsEnabledKey, value);
  }

  // Theme
  String getThemeMode() => _prefs?.getString(AppConstants.themeKey) ?? 'dark';

  Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(AppConstants.themeKey, mode);
  }

  // Tutorial
  bool getTutorialShown() => _prefs?.getBool(AppConstants.tutorialShownKey) ?? false;

  Future<void> setTutorialShown(bool value) async {
    await _prefs?.setBool(AppConstants.tutorialShownKey, value);
  }
}
