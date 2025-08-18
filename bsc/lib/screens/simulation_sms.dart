import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'summary.dart';
import 'package:audioplayers/audioplayers.dart';
class SimulationSmsScreen extends StatefulWidget {
  final Map<String, dynamic> scenario;

  const SimulationSmsScreen({super.key, required this.scenario});

  @override
  State<SimulationSmsScreen> createState() => _SimulationSmsScreenState();
}

class _SimulationSmsScreenState extends State<SimulationSmsScreen> {
  String? _selectedOutcome;
  bool _showResponses = false;

  @override
  void initState() {
    super.initState();
final sound = widget.scenario['sound'];
if (sound != null) {
  final player = AudioPlayer();
  player.play(AssetSource('audio/$sound'));
}
    if (widget.scenario['vibration'] == true) {
      HapticFeedback.heavyImpact();
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _showResponses = true);
    });
  }

  void _selectResponse(Map<String, dynamic> response) {
    setState(() {
      _selectedOutcome = response['outcome'];
    });

    Future.delayed(const Duration(milliseconds: 700), () {
 Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => SummaryScreen(
      title: widget.scenario['title'],
      outcome: _selectedOutcome,
      scenario: widget.scenario,
    ),
  ),
);

    });
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.scenario['content'];
    final List<Map<String, dynamic>> responses = List<Map<String, dynamic>>.from(
      (widget.scenario['responses'] ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // typowe tło jak w SMS
      appBar: AppBar(
        title: Text("Symulacja: ${widget.scenario['title']}"),
        backgroundColor: const Color(0xFF128C7E), // zieleń WhatsAppa
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wiadomość przychodząca
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const Spacer(),

            if (_showResponses)
              ...responses.map((resp) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () => _selectResponse(resp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCF8C6), // zielona chmurka
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      resp['label'],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
