import 'package:flutter/material.dart';

import '../screens/daily_puzzle_screen.dart';
import '../screens/game_screen.dart';
import '../screens/home_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/statistics_screen.dart';
import 'app_services.dart';

class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String levels = '/levels';
  static const String game = '/game';
  static const String daily = '/daily';
  static const String settings = '/settings';
  static const String stats = '/stats';
}

class AppRoutes {
  static Route<dynamic> generate(
    RouteSettings routeSettings,
    AppServices services,
  ) {
    Widget page;
    switch (routeSettings.name) {
      case RouteNames.splash:
        page = SplashScreen(services: services);
        break;
      case RouteNames.onboarding:
        page = OnboardingScreen(services: services);
        break;
      case RouteNames.home:
        page = HomeScreen(services: services);
        break;
      case RouteNames.levels:
        page = LevelSelectScreen(services: services);
        break;
      case RouteNames.game:
        final id = routeSettings.arguments is int
            ? routeSettings.arguments as int
            : 1;
        final puzzle =
            services.repository.levelById(id) ??
            services.repository.levels.first;
        page = GameScreen(services: services, puzzle: puzzle);
        break;
      case RouteNames.daily:
        page = DailyPuzzleScreen(services: services);
        break;
      case RouteNames.settings:
        page = SettingsScreen(services: services);
        break;
      case RouteNames.stats:
        page = StatisticsScreen(services: services);
        break;
      default:
        page = SplashScreen(services: services);
    }
    return MaterialPageRoute(builder: (_) => page, settings: routeSettings);
  }
}
