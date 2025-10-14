import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'scenario.dart';
import 'summary.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import '../progress.dart';
import 'package:provider/provider.dart';
import '../services/tts_service.dart';
import '../accessibility_settings.dart';

class SimulationCallScreen extends StatefulWidget {
  final Scenario scenario;
  final bool fromRandom;
  const SimulationCallScreen({super.key, required this.scenario, this.fromRandom = false});

  @override
  State<SimulationCallScreen> createState() => _SimulationCallScreenState();
}

class _SimulationCallScreenState extends State<SimulationCallScreen> {
  late final AudioPlayer _player;
  bool _inCall = false;
  bool _hasAvatar = false;
  String? _avatar;
  String? _speechFile;
  Map<String, dynamic>? _node; // multi-step state
  bool _awaitOptionsAfterAudio = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerComplete.listen((event) async {
      if (!mounted) return;
      if (_inCall && _awaitOptionsAfterAudio) {
        _awaitOptionsAfterAudio = false;
        final s = Provider.of<A11ySettings>(context, listen: false);
        if (s.ttsEnabled) {
          await _speakCurrentOptions();
        }
      }
    });
    final sound = widget.scenario.sound ?? 'ringtone.mp3';
    _player.setReleaseMode(ReleaseMode.loop);
    _player.play(AssetSource('audio/$sound'));
    if (widget.scenario.vibration) {
      Haptics.notify(context);
    }
    final caller = widget.scenario.caller ?? const {};
    _avatar = caller['avatar']?.toString();
    _speechFile = widget.scenario.voice; // when null, we'll use TTS
    if (_avatar != null) {
      rootBundle
          .load('assets/images/$_avatar')
          .then((_) => mounted ? setState(() => _hasAvatar = true) : null)
          .catchError((_) {});
    }
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _acceptCall() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => _inCall = true);
    // Start spoken dialogue once the call is accepted
    final f = _speechFile;
    if (f != null && f.isNotEmpty) {
      _player.setReleaseMode(ReleaseMode.stop);
      _awaitOptionsAfterAudio = true;
      await _player.play(AssetSource('audio/' + f));
    } else {
      final s = Provider.of<A11ySettings>(context, listen: false);
      if (s.ttsEnabled) {
        final base = widget.scenario.dialogue ?? '';
        final text = _composeDialogueWithOptions(base);
        await TtsService.instance.speak(text, rate: s.ttsRate, volume: s.ttsVolume, language: 'pl-PL');
      }
    }
  }

  Future<void> _declineCall() async {
    await _player.stop();
    final key = widget.scenario.onDeclineOutcome;
    final outcome = key == null ? null : widget.scenario.outcomes[key] as Map<String, dynamic>?;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(outcome: outcome ?? _neutralOutcome(), suggestRandom: widget.fromRandom),
      ),
    );
  }

  Future<void> _goToOutcome(String outcomeKey) async {
    await _player.stop();
    final outcome = widget.scenario.outcomes[outcomeKey] as Map<String, dynamic>?;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(outcome: outcome ?? _neutralOutcome()),
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
    final caller = widget.scenario.caller ?? const {};
    final name = caller['name']?.toString() ?? 'Nieznany';
    final number = caller['number']?.toString() ?? '';
    final dialogue = widget.scenario.dialogue ?? '';

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !_inCall
              ? _IncomingCall(
                  name: name,
                  number: number,
                  avatar: _hasAvatar && _avatar != null ? 'assets/images/$_avatar' : null,
                  onAccept: _acceptCall,
                  onDecline: _declineCall,
                )
              : _InCall(
                  name: name,
                  number: number,
                  dialogue: (_node != null ? (_node!['prompt']?.toString() ?? '') : null) ?? dialogue,
                  hint: _node?['hint']?.toString(),
                  onEnd: _declineCall,
                  onChoice: (c) async {
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
                      final vf = (next['voice'] ?? next['sound'])?.toString();
                      if (vf != null && vf.isNotEmpty) {
                        await _player.stop();
                        _player.setReleaseMode(ReleaseMode.stop);
                        _awaitOptionsAfterAudio = true;
                        await _player.play(AssetSource('audio/' + vf));
                      } else {
                        final s = Provider.of<A11ySettings>(context, listen: false);
                        if (s.ttsEnabled) {
                          final text = _composeDialogueWithOptions((_node?['prompt']?.toString() ?? '').trim());
                          if (text.isNotEmpty) {
                            await TtsService.instance.speak(text, rate: s.ttsRate, volume: s.ttsVolume, language: 'pl-PL');
                          }
                        }
                      }
                      Haptics.notify(context);
                    }
                  },
                  choices: _currentChoices(),
                ),
        ),
      ),
    );
  }
}

class _IncomingCall extends StatelessWidget {
  final String name;
  final String number;
  final String? avatar;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _IncomingCall({
    required this.name,
    required this.number,
    required this.avatar,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 48,
            backgroundImage: avatar != null ? AssetImage(avatar!) : null,
            child: avatar == null ? const Icon(Icons.person, size: 48) : null,
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(number, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const Spacer(),
          const Text('Połączenie przychodzące', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _roundAction(context,
                color: Colors.red,
                icon: Icons.call_end,
                label: 'Odrzuć',
                onTap: onDecline,
              ),
              _roundAction(context,
                color: Colors.green,
                icon: Icons.call,
                label: 'Odbierz',
                onTap: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundAction(BuildContext context, {required Color color, required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkResponse(
          onTap: () { ClickSounds.play(); Haptics.tap(context); onTap(); },
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ]),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InCall extends StatelessWidget {
  final String name;
  final String number;
  final String dialogue;
  final String? hint;
  final VoidCallback onEnd;
  final List<Map<String, dynamic>> choices;
  final void Function(Map<String, dynamic> choice) onChoice;
  const _InCall({
    required this.name,
    required this.number,
    required this.dialogue,
    required this.hint,
    required this.onEnd,
    required this.choices,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(name),
          subtitle: Text(number),
          trailing: IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () { ClickSounds.play(); onEnd(); },
            tooltip: 'Zakończ',
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dialogue, style: const TextStyle(fontSize: 18, height: 1.4)),
                if (Provider.of<Progress>(context, listen: true).trainingMode && (hint != null && hint!.isNotEmpty)) ...[
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
                        Expanded(child: Text(hint!)),
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
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, -2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Co odpowiesz?', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...choices.map((c) {
                  final label = (c['text'] ?? c['label'] ?? 'Wybierz').toString();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.record_voice_over),
                      onPressed: () { ClickSounds.play(); onChoice(c); },
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
    );
  }
}

extension on _SimulationCallScreenState {
  List<Map<String, dynamic>> _currentChoices() {
    final v = _node?['choices'];
    if (v is List) {
      return v.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return widget.scenario.choices;
  }

  String _optionsText() {
    final choices = _currentChoices();
    if (choices.isEmpty) return '';
    final labels = <String>[];
    for (var i = 0; i < choices.length; i++) {
      final label = (choices[i]['text'] ?? choices[i]['label'] ?? 'Wybierz').toString();
      labels.add('${i + 1}. $label');
    }
    return 'Opcje: ${labels.join(', ')}';
  }

  String _composeDialogueWithOptions(String dialogue) {
    final opts = _optionsText();
    if (opts.isEmpty) return dialogue;
    if (dialogue.trim().isEmpty) return opts;
    return '$dialogue. $opts';
  }

  Future<void> _speakCurrentOptions() async {
    final s = Provider.of<A11ySettings>(context, listen: false);
    final text = _optionsText();
    if (text.isNotEmpty) {
      await TtsService.instance.speak(text, rate: s.ttsRate, volume: s.ttsVolume, language: 'pl-PL');
    }
  }
}
