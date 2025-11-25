import 'package:flutter/material.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/level_select_menu/level_select_menu.dart';
import '../presentation/game_screen/game_screen.dart';
import '../presentation/onboarding_tutorial/onboarding_tutorial.dart';
import '../presentation/level_complete_screen/level_complete_screen.dart';

class AppRoutes {
  /// ROUTE NAMES
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String levelSelectMenu = '/level-select-menu';
  static const String game = '/game-screen';
  static const String onboardingTutorial = '/onboarding-tutorial';
  static const String levelComplete = '/level-complete-screen';

  /// ROUTE MAP
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    levelSelectMenu: (context) => const LevelSelectMenu(),
    game: (context) => const GameScreen(),
    onboardingTutorial: (context) => const OnboardingTutorial(),
    levelComplete: (context) => const LevelCompleteScreen(),
  };
}
