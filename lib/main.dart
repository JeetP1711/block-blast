import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'services/storage_service.dart';
import 'services/haptic_service.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E1F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final hapticService = HapticService();
  hapticService.setEnabled(storageService.getHapticEnabled());

  final soundService = SoundService();
  soundService.setSoundEnabled(storageService.getSoundEnabled());
  soundService.setMusicEnabled(storageService.getMusicEnabled());

  runApp(BlockBurstApp(
    storageService: storageService,
    hapticService: hapticService,
    soundService: soundService,
  ));
}
