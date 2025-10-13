import 'package:flutter/material.dart';
import 'scenario.dart';
import 'simulation.dart';
import 'package:flutter/services.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import 'simulation_mode.dart';
import 'settings.dart';
import 'about.dart';
import 'stats.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color tileColor = const Color(0xFFD4B483); // beżowy
    final Color textColor = Colors.black87;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          color: Colors.black38, // przyciemnienie tła
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Menu główne",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuTile(
                        context,
                        title: "Tryb pokazowy",
                        icon: Icons.school,
                        color: tileColor,
                        textColor: textColor,
                        onTap: () async {
                          try {
                            final jsonStr = await rootBundle.loadString('assets/data/scenarios.json');
                            final scenarios = Scenario.listFromJsonString(jsonStr);
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SimulationScreen(scenarios: scenarios),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nie udało się wczytać scenariuszy')),
                            );
                          }
                        },
                      ),
                      _buildMenuTile(
                        context,
                        title: "Statystyki",
                        icon: Icons.insights,
                        color: tileColor,
                        textColor: textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StatsScreen()),
                          );
                        },
                      ),
                      _buildMenuTile(
                        context,
                        title: "Tryb symulacyjny",
                        icon: Icons.play_circle_fill,
                        color: tileColor,
                        textColor: textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SimulationModeScreen()),
                          );
                        },
                      ),
                      _buildMenuTile(
                        context,
                        title: "Ustawienia",
                        icon: Icons.settings,
                        color: tileColor,
                        textColor: textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                      _buildMenuTile(
                        context,
                        title: "O aplikacji",
                        icon: Icons.info,
                        color: tileColor,
                        textColor: textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () { ClickSounds.play(); Haptics.tap(context); onTap(); },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: textColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
