import 'dart:math';

class Helpers {
  static final Random _random = Random();

  static int randomInt(int max) => _random.nextInt(max);

  static T randomFrom<T>(List<T> list) => list[_random.nextInt(list.length)];

  static String formatScore(int score) {
    if (score < 1000) return score.toString();
    if (score < 1000000) {
      final thousands = score ~/ 1000;
      final remainder = score % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return score.toString();
  }
}
