import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'simulation.dart';

class ScenarioScreen extends StatelessWidget {
  const ScenarioScreen({super.key});

  Future<List<Map<String, dynamic>>> loadScenarios() async {
    final String jsonString = await rootBundle.loadString('assets/data/scenarios.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(jsonList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E3),
      appBar: AppBar(
        title: const Text("Wybierz scenariusz"),
        backgroundColor: const Color(0xFFD4B483),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadScenarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Błąd wczytywania danych"));
          } else {
            final scenarios = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: scenarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = scenarios[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SimulationScreen(scenario: item),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4B483),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIcon(item['icon']),
                          size: 36,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['type'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'local_shipping':
        return Icons.local_shipping;
      case 'phone_in_talk':
        return Icons.phone_in_talk;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'message':
        return Icons.message;
      default:
        return Icons.warning;
    }
  }
}