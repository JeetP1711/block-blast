import 'package:flutter/material.dart';
import 'theme.dart';
import '../screens/home_screen.dart';
import '../screens/game_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tutorial_screen.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';

class BlockBurstApp extends StatelessWidget {
  final StorageService storageService;
  final HapticService hapticService;
  final SoundService soundService;

  const BlockBurstApp({
    super.key,
    required this.storageService,
    required this.hapticService,
    required this.soundService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Burst',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _buildRoute(
              HomeScreen(
                storageService: storageService,
                hapticService: hapticService,
                soundService: soundService,
              ),
            );
          case '/game':
            return _buildRoute(
              GameScreen(
                storageService: storageService,
                hapticService: hapticService,
                soundService: soundService,
              ),
            );
          case '/settings':
            return _buildRoute(
              SettingsScreen(
                storageService: storageService,
                hapticService: hapticService,
                soundService: soundService,
              ),
            );
          case '/tutorial':
            return _buildRoute(const TutorialScreen());
          default:
            return _buildRoute(
              HomeScreen(
                storageService: storageService,
                hapticService: hapticService,
                soundService: soundService,
              ),
            );
        }
      },
    );
  }

  PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
