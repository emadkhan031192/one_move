import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'app_services.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget. Rebuilds on settings changes (theme mode).
class OneMoveApp extends StatelessWidget {
  final AppServices services;

  const OneMoveApp({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: services.settings,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: services.settings.darkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: RouteNames.splash,
          onGenerateRoute: (settings) => AppRoutes.generate(settings, services),
        );
      },
    );
  }
}
