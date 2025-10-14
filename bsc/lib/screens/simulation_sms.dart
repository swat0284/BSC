import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
// services not needed directly here
import 'scenario.dart';
import 'summary.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import '../progress.dart';
import 'package:provider/provider.dart';
import '../services/tts_service.dart';
import '../accessibility_settings.dart';

class SimulationSmsScreen extends StatefulWidget {
  final Scenario scenario;
  final bool fromRandom;
  const SimulationSmsScreen({super.key, required this.scenario, this.fromRandom = false});

  @override
  State<SimulationSmsScreen> createState() => _SimulationSmsScreenState();
}

class _SimulationSmsScreenState extends State<SimulationSmsScreen> {
  late final AudioPlayer _player;
  Map<String, dynamic>? _node; // multi-step state
  bool _ttsSpeaking = false;
  bool _awaitAfterSound = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerComplete.listen((event) async {
      if (!mounted) return;
      if (_awaitAfterSound) {
        _awaitAfterSound = false;
        await _maybeSpeakCurrent();
      }
    });
    final sound = widget.scenario.sound ?? 'sms_alert.mp3';
    _player.setReleaseMode(ReleaseMode.stop);
    _awaitAfterSound = true;
    _player.play(AssetSource('audio/$sound'));
    if (widget.scenario.vibration) {
      Haptics.notify(context);
    }
    // Optionally speak the message after first frame
    // If there was no sound, speak after first frame fallback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_awaitAfterSound) await _maybeSpeakCurrent();
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _goToOutcome(String outcomeKey) async {
    await _player.stop();
    final outcome = widget.scenario.outcomes[outcomeKey] as Map<String, dynamic>?;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(outcome: outcome ?? _neutralOutcome(), suggestRandom: widget.fromRandom),
      ),
    );
  }

  Map<String, dynamic> _neutralOutcome() => {
        'reaction': 'neutralna',
        'title': 'Brak danych wyniku',
        'image': 'info.png',
        'imageAlt': 'Informacja',
        'summary': 'Ten wybór nie ma zdefiniowanego podsumowania.',
        'advice': 'Zgłoś to twórcom, aby uzupełnić scenariusz.'
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msg = (_node != null ? (_node!['prompt']?.toString() ?? '') : null) ?? (widget.scenario.content ?? '');
    // Tryb treningowy – podpowiedź do bieżącego kroku
    final training = Provider.of<Progress>(context, listen: true).trainingMode;
    final sender = _senderFrom(msg);
    final time = _formatTimeNow();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sender, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('SMS', style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          Consumer<A11ySettings>(
            builder: (_, s, __) {
              return IconButton(
                tooltip: !s.ttsEnabled
                    ? 'Włącz TTS i czytaj na głos'
                    : (_ttsSpeaking ? 'Zatrzymaj czytanie' : 'Czytaj na głos'),
                icon: Icon(!s.ttsEnabled
                    ? Icons.volume_up_outlined
                    : (_ttsSpeaking ? Icons.stop : Icons.volume_up)),
                onPressed: () async {
                  if (!s.ttsEnabled) {
                    s.update((x) => x.ttsEnabled = true);
                    await _maybeSpeakCurrent();
                    return;
                  }
                  if (_ttsSpeaking) {
                    await TtsService.instance.stop();
                    if (mounted) setState(() => _ttsSpeaking = false);
                  } else {
                    final msgText = (_node != null ? (_node!['prompt']?.toString() ?? '') : null) ?? (widget.scenario.content ?? '');
                    await _speakText(_ttsTextFor(msgText));
                  }
                },
              );
            },
          ),
          const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Dziś • $time',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 18, child: Icon(Icons.sms)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFFF1F0F5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            msg,
                            style: const TextStyle(fontSize: 17, height: 1.35),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Teraz', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  if (training && (_node?['hint'] != null)) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text((_node!['hint']).toString())),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // atrapka pola wpisywania
                  Row(
                    children: [
                      Expanded(
                        child: IgnorePointer(
                          ignoring: true,
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Napisz wiadomość…',
                              filled: true,
                              fillColor: theme.brightness == Brightness.dark
                                  ? const Color(0xFF222222)
                                  : const Color(0xFFF3F3F3),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(onPressed: null, icon: const Icon(Icons.send), disabledColor: theme.disabledColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Możliwe reakcje', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._currentChoices().map((c) {
                    final label = (c['label'] ?? c['text'] ?? 'Wybierz').toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.reply),
                        onPressed: () async {
                          ClickSounds.play();
                          Haptics.tap(context);
                          final outcomeKey = c['outcome'] as String?;
                          final next = c['next'];
                          if (outcomeKey != null) {
                            final outcome = widget.scenario.outcomes[outcomeKey] as Map<String, dynamic>?;
                            final reaction = outcome?['reaction']?.toString() ?? '';
                            Haptics.outcome(context, reaction);
                            // punkty
                            Provider.of<Progress>(context, listen: false).award(reaction);
                            _goToOutcome(outcomeKey);
                          } else if (next is Map<String, dynamic>) {
                            setState(() => _node = next);
                            final f = next['sound']?.toString();
                            if (f != null && f.isNotEmpty) {
                              await _player.stop();
                              _player.setReleaseMode(ReleaseMode.stop);
                              _awaitAfterSound = true;
                              await _player.play(AssetSource('audio/' + f));
                            }
                            Haptics.notify(context);
                          if (f == null || f.isEmpty) {
                            await _maybeSpeakCurrent();
                          }
                          }
                        },
                        label: Text(label),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _senderFrom(String text) {
    final url = _extractUrl(text);
    if (url == null) return 'Nieznany nadawca';
    return url.host.isNotEmpty ? url.host : 'Nieznany nadawca';
  }

  Uri? _extractUrl(String text) {
    final reg = RegExp(r"https?://[^\s]+", caseSensitive: false);
    final match = reg.firstMatch(text);
    if (match == null) return null;
    return Uri.tryParse(match.group(0)!);
  }

  List<Map<String, dynamic>> _currentChoices() {
    final v = _node?['choices'];
    if (v is List) {
      return v.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return widget.scenario.choices;
  }

  // --- TTS helpers ---
  String _ttsTextFor(String fallbackMsg) {
    final nodeTts = _node?['ttsText']?.toString();
    if (nodeTts != null && nodeTts.isNotEmpty) return nodeTts;
    final a11y = widget.scenario.a11y ?? const {};
    final scenTts = a11y['ttsText']?.toString();
    if (scenTts != null && scenTts.isNotEmpty) return scenTts;
    final opts = _currentChoices();
    if (opts.isNotEmpty) {
      final labels = <String>[];
      for (var i = 0; i < opts.length; i++) {
        final label = (opts[i]['label'] ?? opts[i]['text'] ?? 'Wybierz').toString();
        labels.add('${i + 1}. $label');
      }
      return '$fallbackMsg. Opcje: ${labels.join(', ')}';
    }
    return fallbackMsg;
  }

  Future<void> _maybeSpeakCurrent() async {
    final s = Provider.of<A11ySettings>(context, listen: false);
    if (!s.ttsEnabled) return;
    final msg = (_node != null ? (_node!['prompt']?.toString() ?? '') : null) ?? (widget.scenario.content ?? '');
    await _speakText(_ttsTextFor(msg));
  }

  Future<void> _speakText(String text) async {
    final s = Provider.of<A11ySettings>(context, listen: false);
    await TtsService.instance.speak(text, rate: s.ttsRate, volume: s.ttsVolume, language: 'pl-PL');
    if (mounted) setState(() => _ttsSpeaking = true);
  }
}
