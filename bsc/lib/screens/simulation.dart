import 'package:flutter/material.dart';
import 'scenario.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import 'scenario_detail.dart';


class SimulationScreen extends StatefulWidget {
final List<Scenario> scenarios;
const SimulationScreen({super.key, required this.scenarios});


@override
State<SimulationScreen> createState() => _SimulationScreenState();
}


class _SimulationScreenState extends State<SimulationScreen> {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
  title: const Text('Symulacje'),
  actions: [
    IconButton(
      tooltip: 'Menu',
      icon: const Icon(Icons.home),
      onPressed: () {
        ClickSounds.play();
        Haptics.tap(context);
        Navigator.of(context).pushNamedAndRemoveUntil('/menu', (r) => false);
      },
    ),
  ],
),
body: ListView.separated(
itemCount: widget.scenarios.length,
separatorBuilder: (_, __) => const Divider(height: 1),
itemBuilder: (_, i) {
final s = widget.scenarios[i];
return ListTile(
leading: Icon(_iconFor(s.icon)),
title: Text(s.title),
subtitle: Text(s.description),
trailing: const Icon(Icons.chevron_right),
onTap: () => Navigator.push(
context,
MaterialPageRoute(builder: (_) => ScenarioDetail(scenario: s)),
),
);
},
),
);
}


IconData _iconFor(String materialIconName) {
// Minimal mapping; optionally extend
switch (materialIconName) {
case 'local_shipping':
return Icons.local_shipping;
case 'phone_in_talk':
return Icons.phone_in_talk;
case 'family_restroom':
return Icons.family_restroom;
case 'card_giftcard':
return Icons.card_giftcard;
default:
return Icons.warning_amber_rounded;
}
}
}
