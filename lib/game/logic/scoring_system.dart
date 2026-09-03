import '../../utils/constants.dart';

/// Handles all scoring logic.
class ScoringSystem {
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  bool _newHighScore = false;

  int get score => _score;
  int get highScore => _highScore;
  int get combo => _combo;
  bool get isNewHighScore => _newHighScore;

  void setHighScore(int saved) {
    _highScore = saved;
  }

  /// Score for placing a block (based on cell count).
  int scorePlacement(int cellCount) {
    final points = cellCount * AppConstants.placeBlockScore;
    _score += points;
    _checkHighScore();
    return points;
  }

  /// Score for clearing lines.
  /// Returns the points earned from this clear.
  int scoreClear(int lineCount) {
    if (lineCount <= 0) {
      _combo = 0;
      return 0;
    }

    _combo++;

    // Base score from lines
    final idx = lineCount.clamp(0, AppConstants.lineClearScores.length - 1);
    int basePoints = AppConstants.lineClearScores[idx];

    // Combo multiplier
    double comboMultiplier = 1.0;
    if (_combo >= 2) {
      comboMultiplier = 1.0 + (_combo - 1) * 0.5; // x1.5, x2.0, x2.5, ...
    }

    final points = (basePoints * comboMultiplier).round();
    _score += points;
    _checkHighScore();
    return points;
  }

  /// Call when a placement does NOT result in a clear.
  void resetCombo() {
    _combo = 0;
  }

  void _checkHighScore() {
    if (_score > _highScore) {
      _highScore = _score;
      _newHighScore = true;
    }
  }

  void reset() {
    _score = 0;
    _combo = 0;
    _newHighScore = false;
  }

  void resetNewHighScoreFlag() {
    _newHighScore = false;
  }
}
