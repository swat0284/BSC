import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'scenario.dart';
import 'summary.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import '../progress.dart';
import 'package:provider/provider.dart';
import '../services/tts_service.dart';
import '../accessibility_settings.dart';

class SimulationWebScreen extends StatefulWidget {
  final Scenario scenario;
  final bool fromRandom;
  const SimulationWebScreen({super.key, required this.scenario, this.fromRandom = false});

  @override
  State<SimulationWebScreen> createState() => _SimulationWebScreenState();
}

class _SimulationWebScreenState extends State<SimulationWebScreen> {
  late final AudioPlayer _player;
  Map<String, dynamic>? _node; // multi-step state
  bool _ttsSpeaking = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    final sound = widget.scenario.sound ?? 'notification.mp3';
    _player.setReleaseMode(ReleaseMode.stop);
    _player.play(AssetSource('audio/$sound'));
    if (widget.scenario.vibration) {
      Haptics.notify(context);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSpeakCurrent());
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
    final content = (_node != null ? (_node!['prompt']?.toString() ?? '') : null) ?? (widget.scenario.content ?? '');
    final nodeImage = _node?['image']?.toString();
    final nodeImageAlt = _node?['imageAlt']?.toString();
    final pageImage = nodeImage ?? widget.scenario.pageImage;
    final pageImageAlt = nodeImageAlt ?? widget.scenario.pageImageAlt ?? '';
    final url = _extractUrl(content);
    final host = url?.host ?? 'nieznana-strona';
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Consumer<A11ySettings>(
              builder: (_, s, __) {
                return _BrowserBar(
                  host: host,
                  url: url?.toString() ?? content,
                  trailing: [
                    IconButton(
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
                          final text = _ttsTextFor(content);
                          await _speakText(text);
                        }
                      },
                    ),
                    IconButton(onPressed: () { ClickSounds.play(); Haptics.tap(context); }, icon: const Icon(Icons.more_vert)),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.scenario.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (pageImage != null && pageImage.isNotEmpty) ...[
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset('assets/images/' + pageImage, semanticLabel: pageImageAlt, fit: BoxFit.cover),
                              ),
                            ),
                          ] else ...[
                            Text(content, style: const TextStyle(fontSize: 16, height: 1.4)),
                          ],
                          if (Provider.of<Progress>(context, listen: true).trainingMode && (_node?['hint'] != null)) ...[
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
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, -2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Co zrobisz?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._currentChoices().map((c) {
                    final label = (c['label'] ?? c['text'] ?? 'Wybierz').toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.touch_app),
                        onPressed: () async {
                          ClickSounds.play();
                          Haptics.tap(context);
                          final outcomeKey = c['outcome'] as String?;
                          final next = c['next'];
                          if (outcomeKey != null) {
                            final outcome = widget.scenario.outcomes[outcomeKey] as Map<String, dynamic>?;
                            final reaction = outcome?['reaction']?.toString() ?? '';
                            Haptics.outcome(context, reaction);
                            Provider.of<Progress>(context, listen: false).award(reaction);
                            _goToOutcome(outcomeKey);
                          } else if (next is Map<String, dynamic>) {
                            setState(() => _node = next);
                            final f = next['sound']?.toString();
                            if (f != null && f.isNotEmpty) {
                              await _player.stop();
                              _player.setReleaseMode(ReleaseMode.stop);
                              await _player.play(AssetSource('audio/' + f));
                            }
                            Haptics.notify(context);
                            _maybeSpeakCurrent();
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

  Uri? _extractUrl(String text) {
    final reg = RegExp(r"https?://[^\s]+", caseSensitive: false);
    final match = reg.firstMatch(text);
    if (match == null) return null;
    final s = match.group(0)!;
    return Uri.tryParse(s);
  }
}

extension on _SimulationWebScreenState {
  List<Map<String, dynamic>> _currentChoices() {
    final v = _node?['choices'];
    if (v is List) {
      return v.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return widget.scenario.choices;
  }
}

extension ttsHelpers on _SimulationWebScreenState {
  String _ttsTextFor(String fallbackMsg) {
    final nodeTts = _node?['ttsText']?.toString();
    if (nodeTts != null && nodeTts.isNotEmpty) return nodeTts;
    final a11y = widget.scenario.a11y ?? const {};
    final scenTts = a11y['ttsText']?.toString();
    if (scenTts != null && scenTts.isNotEmpty) return scenTts;
    return fallbackMsg;
  }

  Future<void> _maybeSpeakCurrent() async {
    final s = Provider.of<A11ySettings>(context, listen: false);
    if (!s.ttsEnabled) return;
    final content = (_node != null ? (_node!['prompt']?.toString() ?? '') : null) ?? (widget.scenario.content ?? '');
    await _speakText(_ttsTextFor(content));
  }

  Future<void> _speakText(String text) async {
    final s = Provider.of<A11ySettings>(context, listen: false);
    await TtsService.instance.speak(text, rate: s.ttsRate, volume: s.ttsVolume, language: 'pl-PL');
    if (mounted) setState(() => _ttsSpeaking = true);
  }
}

class _BrowserBar extends StatelessWidget {
  final String host;
  final String url;
  final List<Widget>? trailing;
  const _BrowserBar({required this.host, required this.url, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(onPressed: () { ClickSounds.play(); Haptics.tap(context); Navigator.maybePop(context); }, icon: const Icon(Icons.arrow_back)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      host,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...(trailing ?? [
            IconButton(onPressed: () { ClickSounds.play(); Haptics.tap(context); }, icon: const Icon(Icons.more_vert))
          ]),
        ],
      ),
    );
  }
}

