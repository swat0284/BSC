import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../progress.dart';
import '../click_sounds.dart';
import '../haptics.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<Progress>(context, listen: true);
    final theme = Theme.of(context);
    final dailyTarget = p.dailyTarget.clamp(1, 999);
    final dailyProgress = p.dailyProgress.clamp(0, dailyTarget);
    final dailyRatio = (dailyTarget == 0) ? 0.0 : dailyProgress / dailyTarget;

    return Scaffold(
      appBar: AppBar(title: const Text('Twoje statystyki')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Poziom i punkty
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text('${p.level}', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Poziom i punkty', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Poziom: ${p.level}  •  Punkty: ${p.points}')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cel dzienny
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cel dzienny', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Bezpieczne decyzje: $dailyProgress / $dailyTarget'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: dailyRatio.clamp(0.0, 1.0),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Tryb treningowy', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Switch(
                        value: p.trainingMode,
                        onChanged: (v) {
                          ClickSounds.play();
                          Haptics.tap(context);
                          p.toggleTraining(v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.trainingMode
                        ? 'Podpowiedzi włączone – zobaczysz wskazówki po każdym kroku.'
                        : 'Podpowiedzi wyłączone – pełna symulacja bez sugestii.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Liczniki reakcji
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Twoje decyzje', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CounterTile(icon: Icons.verified, color: Colors.green, label: 'Bezpieczne', value: p.safeCount),
                      const SizedBox(width: 12),
                      _CounterTile(icon: Icons.hourglass_bottom, color: Colors.amber, label: 'Neutralne', value: p.neutralCount),
                      const SizedBox(width: 12),
                      _CounterTile(icon: Icons.warning_amber_rounded, color: Colors.redAccent, label: 'Ryzykowne', value: p.riskyCount),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Odznaki
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Odznaki', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (p.badges.isEmpty)
                    Text('Brak odznak – graj i zbieraj osiągnięcia!', style: theme.textTheme.bodySmall)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.badges.map((b) => Chip(label: Text(_badgeLabel(b)), avatar: const Icon(Icons.military_tech))).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _badgeLabel(String id) {
    switch (id) {
      case 'pierwsza_bezpieczna':
        return 'Pierwsza bezpieczna';
      case 'dziesiec_bezpiecznych':
        return '10 bezpiecznych';
      case '100_punktow':
        return '100 punktów';
      case 'cel_dzienny':
        return 'Cel dzienny';
      default:
        return id;
    }
  }
}

class _CounterTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;
  const _CounterTile({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

