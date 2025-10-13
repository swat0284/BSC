import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'scenario.dart';
import 'scenario_detail.dart';
import '../haptics.dart';

class SimulationModeBadge extends StatelessWidget {
  final String simulationType;
  const SimulationModeBadge({super.key, required this.simulationType});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _dataFor(simulationType);
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  (String, Color, IconData) _dataFor(String t) {
    switch (t) {
      case 'sms':
        return ('SMS', Colors.blue, Icons.sms);
      case 'call':
        return ('CALL', Colors.green, Icons.call);
      case 'web':
        return ('WEB', Colors.orange, Icons.language);
      default:
        return ('?', Colors.grey, Icons.help_outline);
    }
  }
}

class SimulationModeScreen extends StatefulWidget {
  const SimulationModeScreen({super.key});

  @override
  State<SimulationModeScreen> createState() => _SimulationModeScreenState();
}

class _SimulationModeScreenState extends State<SimulationModeScreen> {
  List<Scenario>? _scenarios;
  bool _loading = true;
  String? _error;
  String _difficulty = 'all'; // all|easy|medium|hard
  bool _autoStarted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/scenarios.json');
      final list = Scenario.listFromJsonString(jsonStr);
      setState(() {
        _scenarios = list;
        _loading = false;
      });
      _maybeAutoStart();
    } catch (e) {
      setState(() {
        _error = 'Nie udało się wczytać scenariuszy';
        _loading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAutoStart();
  }

  void _maybeAutoStart() {
    if (_autoStarted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final auto = (args is Map && args['autoStart'] == true);
    if (auto && !_loading && (_scenarios?.isNotEmpty ?? false)) {
      _autoStarted = true;
      Future.microtask(_startRandom);
    }
  }

  void _startRandom() {
    final list = _filtered();
    if (list.isEmpty) return;
    final rnd = Random();
    final totalWeight = list.fold<int>(0, (sum, s) => sum + (s.weight <= 0 ? 1 : s.weight));
    var pick = rnd.nextInt(totalWeight) + 1;
    Scenario picked = list.first;
    for (final s in list) {
      pick -= (s.weight <= 0 ? 1 : s.weight);
      if (pick <= 0) { picked = s; break; }
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScenarioDetail(scenario: picked, fromRandom: true)),
    );
  }

  List<Scenario> _filtered() {
    final list = _scenarios ?? const <Scenario>[];
    if (_difficulty == 'all') return list;
    return list.where((s) => (s.difficulty ?? 'medium') == _difficulty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tryb symulacyjny')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : (_error != null)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () { Haptics.tap(context); _load(); },
                          child: const Text('Spróbuj ponownie'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Losowa symulacja',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Wciśnij przycisk poniżej, by uruchomić losowy scenariusz.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Poziom trudności: '),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _difficulty,
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('Wszystkie')),
                                DropdownMenuItem(value: 'easy', child: Text('Łatwe')),
                                DropdownMenuItem(value: 'medium', child: Text('Średnie')),
                                DropdownMenuItem(value: 'hard', child: Text('Trudne')),
                              ],
                              onChanged: (v) => setState(() => _difficulty = v ?? 'all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () { Haptics.tap(context); _startRandom(); },
                          icon: const Icon(Icons.casino),
                          label: const Text('Start losowej symulacji'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(260, 56)),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
