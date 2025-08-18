import 'package:flutter/material.dart';
import 'simulation_sms.dart';

class SimulationScreen extends StatelessWidget {
  final Map<String, dynamic> scenario;

  const SimulationScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context) {
    final type = scenario['simulationType'];

    if (type == 'sms') {
      return SimulationSmsScreen(scenario: scenario);
    }

    // fallback
    return Scaffold(
      appBar: AppBar(title: const Text("Symulacja")),
      body: const Center(child: Text("Typ symulacji nieobsługiwany")),
    );
  }
}
