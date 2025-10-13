import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'accessibility_settings.dart';
import 'progress.dart';
import 'screens/welcome.dart';
import 'screens/menu.dart';
import 'screens/simulation_mode.dart';
import 'screens/settings.dart';
import 'theme.dart';

void main() {
  runApp(const BscApp());
}

class BscApp extends StatelessWidget {
  const BscApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => A11ySettings()),
        ChangeNotifierProvider(create: (_) {
          final p = Progress();
          // asynchroniczne załadowanie zapisanych statystyk
          p.load();
          return p;
        }),
      ],
      child: Consumer<A11ySettings>(
        builder: (_, s, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bezpieczny Świat Cyfrowy',

            themeMode: s.themeMode,
            theme: buildLightTheme(s.highContrast),
            darkTheme: buildDarkTheme(s.highContrast),

            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
               textScaleFactor: s.textScale.clamp(0.9, 1.25),
              ),
              child: child!,
            ),

            home: const WelcomeScreen(),
            routes: {
              '/settings': (_) => const SettingsScreen(),
              '/menu': (_) => const MenuScreen(),
              '/simulation-mode': (_) => const SimulationModeScreen(),
            },
          );
        },
      ),
    );
  }
}
