import 'package:flutter/material.dart';
import 'simulation.dart';

class ScenarioDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scenario;

  const ScenarioDetailScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context) {
    final title = scenario['title'];
    final type = scenario['type'];
    final description = scenario['description'];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Typ zagrożenia: $type",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SimulationScreen(scenario: scenario),
                  ),
                );
              },
              child: const Text("Rozpocznij symulację"),
            ),
          ],
        ),
      ),
    );
  }
}