import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../accessibility_settings.dart'; // A11ySettings + HapticsLevel
import '../progress.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<A11ySettings>(
      builder: (context, s, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Ustawienia')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SectionHeader('Wygląd i czytelność'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Wysoki kontrast'),
                      subtitle: const Text('Wzmocnione kolory dla lepszej czytelności'),
                      value: s.highContrast,
                      onChanged: (v) => s.update((x) => x.highContrast = v),
                    ),
                    const Divider(height: 1),

                    // --- MOTYW: Dropdown zamiast SegmentedButton ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Motyw', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ThemeMode>(
                            value: s.themeMode,
                            items: const [
                              DropdownMenuItem(value: ThemeMode.system, child: Text('Systemowy')),
                              DropdownMenuItem(value: ThemeMode.light,  child: Text('Jasny')),
                              DropdownMenuItem(value: ThemeMode.dark,   child: Text('Ciemny')),
                            ],
                            onChanged: (v) {
                              if (v != null) s.update((x) => x.themeMode = v);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Wybierz jasny, ciemny lub zgodny z systemem',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // --- KONIEC ZMIANY ---

                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Rozmiar tekstu', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Text('${(s.textScale * 100).round()}%'),
                        ],
                      ),
                    ),
                    Slider(
                      min: 0.9,
                      max: 1.25,         // max 125%
                      divisions: 7,      // krok ~0.05
                      value: s.textScale.clamp(0.9, 1.25),
                      onChanged: (v) => s.update((x) => x.textScale = v),
                      label: '${(s.textScale * 100).round()}%',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _PreviewText(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              _SectionHeader('Dostępność i interakcje'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Większe przyciski'),
                      subtitle: const Text('Zwiększa obszar dotyku i padding'),
                      value: s.largeButtons,
                      onChanged: (v) => s.update((x) => x.largeButtons = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Redukcja animacji'),
                      subtitle: const Text('Ogranicz ruchy i przejścia'),
                      value: s.reduceMotion,
                      onChanged: (v) => s.update((x) => x.reduceMotion = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Etykiety pod ikonami'),
                      subtitle: const Text('Dodaje podpisy do ikon'),
                      value: s.iconLabels,
                      onChanged: (v) => s.update((x) => x.iconLabels = v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Wibracje (haptyka)'),
                      subtitle: Text(_hapticsLabel(s.haptics)),
                      trailing: DropdownButton<HapticsLevel>(
                        value: s.haptics,
                        onChanged: (v) { if (v != null) s.update((x) => x.haptics = v); },
                        items: const [
                          DropdownMenuItem(value: HapticsLevel.off,  child: Text('Wyłączone')),
                          DropdownMenuItem(value: HapticsLevel.low,  child: Text('Niskie')),
                          DropdownMenuItem(value: HapticsLevel.high, child: Text('Wysokie')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              _SectionHeader('Tryb treningowy i cele'),
              Card(
                child: Consumer<Progress>(
                  builder: (context, p, _) {
                    return Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Tryb treningowy'),
                          subtitle: const Text('Pokaż podpowiedzi po każdym kroku'),
                          value: p.trainingMode,
                          onChanged: (v) => p.toggleTraining(v),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Cel dzienny'),
                          subtitle: Text('Bezpieczne decyzje: ${p.dailyTarget}'),
                        ),
                        Slider(
                          min: 1, max: 10, divisions: 9,
                          value: p.dailyTarget.toDouble(),
                          onChanged: (v) => p.setDailyTarget(v.round()),
                          label: '${p.dailyTarget}',
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              _SectionHeader('Czytanie na głos (TTS)'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Czytaj na głos'),
                      subtitle: const Text('Odczytywanie tekstów przez lektora'),
                      value: s.ttsEnabled,
                      onChanged: (v) => s.update((x) => x.ttsEnabled = v),
                    ),
                    if (s.ttsEnabled) const Divider(height: 1),
                    if (s.ttsEnabled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            const Expanded(child: Text('Szybkość mowy', style: TextStyle(fontWeight: FontWeight.w600))),
                            Text(s.ttsRate.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                    if (s.ttsEnabled)
                      Slider(
                        min: 0.7, max: 1.3, divisions: 12,
                        value: s.ttsRate.clamp(0.7, 1.3),
                        onChanged: (v) => s.update((x) => x.ttsRate = v),
                        label: s.ttsRate.toStringAsFixed(1),
                      ),
                    if (s.ttsEnabled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Row(
                          children: [
                            const Expanded(child: Text('Głośność', style: TextStyle(fontWeight: FontWeight.w600))),
                            Text('${(s.ttsVolume * 100).round()}%'),
                          ],
                        ),
                      ),
                    if (s.ttsEnabled)
                      Slider(
                        min: 0.0, max: 1.0, divisions: 10,
                        value: s.ttsVolume.clamp(0.0, 1.0),
                        onChanged: (v) => s.update((x) => x.ttsVolume = v),
                        label: '${(s.ttsVolume * 100).round()}%',
                      ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Napisy do dźwięków'),
                      subtitle: const Text('Pokazuj opisy efektów audio na ekranie'),
                      value: s.captions,
                      onChanged: (v) => s.update((x) => x.captions = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              _SectionHeader('Podgląd przycisków'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ButtonsPreview(large: s.largeButtons),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () => _resetDialog(context, s),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Przywróć domyślne'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _hapticsLabel(HapticsLevel level) {
    switch (level) {
      case HapticsLevel.off:  return 'Wyłączone';
      case HapticsLevel.low:  return 'Niskie';
      case HapticsLevel.high: return 'Wysokie';
    }
  }

  void _resetDialog(BuildContext context, A11ySettings s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Przywrócić ustawienia?'),
        content: const Text('Wszystkie wartości dostępności wrócą do domyślnych.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () {
              s.update((x) {
                x.textScale = 1.1;
                x.highContrast = false;
                x.themeMode = ThemeMode.light;
                x.ttsEnabled = false;
                x.ttsRate = 1.0;
                x.ttsVolume = 1.0;
                x.captions = true;
                x.haptics = HapticsLevel.low;
                x.largeButtons = true;
                x.reduceMotion = false;
                x.iconLabels = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Przywróć'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }
}

class _PreviewText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Przykładowy nagłówek', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('To jest podgląd wielkości czcionki. Zwiększ lub zmniejsz suwak, aby dopasować czytelność.'),
        ],
      ),
    );
  }
}

class _ButtonsPreview extends StatelessWidget {
  final bool large;
  const _ButtonsPreview({required this.large});

  @override
  Widget build(BuildContext context) {
    final pad = large
        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 24)
        : const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
    final minSize = large ? const Size(220, 56) : const Size(180, 44);

    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(padding: pad, minimumSize: minSize),
          child: const Text('Przycisk główny'),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(padding: pad, minimumSize: minSize),
          child: const Text('Przycisk pomocniczy'),
        ),
        TextButton(onPressed: () {}, child: const Text('Tekstowy')),
      ],
    );
  }
}
