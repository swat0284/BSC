import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import 'package:provider/provider.dart';
import '../accessibility_settings.dart';
import '../services/tts_service.dart';

class SummaryScreen extends StatefulWidget {
  final Map<String, dynamic> outcome;
  final bool suggestRandom;
  const SummaryScreen({super.key, required this.outcome, this.suggestRandom = false});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late final AudioPlayer _player;
  bool _ttsSpoken = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerComplete.listen((event) async {
      if (!mounted) return;
      await _maybeSpeakSummary();
    });
    _playOutcomeSound().then((_) {
      // If there was no sound, speak summary right away
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSpeakSummary());
    });
  }

  Future<void> _playOutcomeSound() async {
    try {
      final o = widget.outcome;
      final explicit = o['sound']?.toString();
      final reaction = o['reaction']?.toString() ?? '';
      final file = explicit ?? _defaultSoundForReaction(reaction);
      if (file.isEmpty) return;
      _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource('audio/$file'));
      if (!mounted) return;
      Haptics.outcome(context, reaction);
    } catch (_) {
      // brak pliku lub inny błąd — ignorujemy
    }
  }

  String _defaultSoundForReaction(String reaction) {
    switch (reaction) {
      case 'bezpieczna':
        return 'end_success.mp3';
      case 'niebezpieczna':
        return 'end_warning.mp3';
      case 'współudział':
      case 'neutralna':
      default:
        return 'end_neutral.mp3';
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.outcome['title']?.toString() ?? 'Podsumowanie';
    final summary = widget.outcome['summary']?.toString() ?? '';
    final advice = widget.outcome['advice']?.toString() ?? '';
    final image = widget.outcome['image']?.toString();
    final imageAlt = widget.outcome['imageAlt']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Center(
                child: Image.asset('assets/images/$image', semanticLabel: imageAlt),
              ),
            const SizedBox(height: 16),
            Text(summary, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(advice, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.suggestRandom) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        ClickSounds.play();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/simulation-mode',
                          (r) => false,
                          arguments: { 'autoStart': true },
                        );
                      },
                      icon: const Icon(Icons.casino),
                      label: const Text('Losuj kolejną'),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      ClickSounds.play();
                      Navigator.of(context).pushNamedAndRemoveUntil('/menu', (r) => false);
                    },
                    child: const Text('Wróć do menu'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _maybeSpeakSummary() async {
    if (_ttsSpoken) return;
    final s = Provider.of<A11ySettings>(context, listen: false);
    if (!s.ttsEnabled) return;
    final title = widget.outcome['title']?.toString() ?? 'Podsumowanie';
    final summary = widget.outcome['summary']?.toString() ?? '';
    final advice = widget.outcome['advice']?.toString() ?? '';
    final text = [title, summary, advice].where((e) => e.trim().isNotEmpty).join('. ');
    if (text.isEmpty) return;
    await TtsService.instance.speak(text, rate: s.ttsRate, volume: s.ttsVolume, language: 'pl-PL');
    _ttsSpoken = true;
  }
}
