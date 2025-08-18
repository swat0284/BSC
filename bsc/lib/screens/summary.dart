import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final String title;
  final String? outcome;
  final Map<String, dynamic>? scenario;

  const SummaryScreen({
    super.key,
    required this.title,
    this.outcome,
    this.scenario,
  });

  Color _reactionColor(String reaction) {
    switch (reaction) {
      case 'bezpieczna':
        return const Color.fromRGBO(83, 166, 58,1);
      case 'niebezpieczna':
        return const Color.fromRGBO(203, 58, 41, 1);
      case 'współudział':
        return const Color.fromRGBO(252, 200, 75, 1);
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outcomeData = scenario?['outcomes']?[outcome] ?? {};
    final reactionType = outcomeData['reaction'] ?? 'brak';
    final reactionTitle = outcomeData['title'] ?? 'Podsumowanie';
    final summary = outcomeData['summary'] ?? 'Brak opisu.';
    final advice = outcomeData['advice'] ?? 'Brak porady.';
    final image = outcomeData['image'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Podsumowanie: $title"),
        backgroundColor: const Color(0xFFD4B483),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        color: _reactionColor(reactionType),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Center(
                child: Image.asset(
                  'assets/images/$image',
                  width: 200,
                  height: 200,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              reactionTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Co warto zapamiętać:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              advice,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Powrót do menu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
