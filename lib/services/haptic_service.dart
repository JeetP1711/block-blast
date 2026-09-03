import 'package:flutter/services.dart';

/// Handles haptic feedback.
class HapticService {
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void lightImpact() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  void selectionClick() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  void vibrate() {
    if (_enabled) HapticFeedback.vibrate();
  }
}
