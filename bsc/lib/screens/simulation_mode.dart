import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'scenario.dart';
import 'simulation.dart';

class SimulationModeScreen extends StatelessWidget {
  const SimulationModeScreen({super.key});

  Future<List<Map<String, dynamic>>> loadScenarios() async {
    final String jsonString = await rootBundle.loadString('assets/data/scenarios.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(jsonList);
  }

  void _startRandomScenario(BuildContext context, List<Map<String, dynamic>> scenarios) {
    final random = Random();
    final scenario = scenarios[random.nextInt(scenarios.length)];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SimulationScreen(scenario: scenario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E3),
      appBar: AppBar(
        title: const Text("Tryb pokazowy"),
        backgroundColor: const Color(0xFFD4B483),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadScenarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Błąd wczytywania scenariuszy"));
          } else {
            final scenarios = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildButton(
                    icon: Icons.shuffle,
                    label: "Losowy scenariusz",
                    onTap: () => _startRandomScenario(context, scenarios),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    icon: Icons.list_alt,
                    label: "Wybierz scenariusz",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScenarioScreen()),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4B483),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
