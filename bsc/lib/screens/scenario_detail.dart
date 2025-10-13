import 'package:flutter/material.dart';
import 'scenario.dart';
import 'simulation_sms.dart';
import 'simulation_call.dart';
import 'simulation_web.dart';


class ScenarioDetail extends StatelessWidget {
  final Scenario scenario;
  final bool fromRandom;
  const ScenarioDetail({super.key, required this.scenario, this.fromRandom = false});


@override
Widget build(BuildContext context) {
    switch (scenario.simulationType) {
      case 'sms':
        return SimulationSmsScreen(scenario: scenario, fromRandom: fromRandom);
      case 'call':
        return SimulationCallScreen(scenario: scenario, fromRandom: fromRandom);
      case 'web':
        return SimulationWebScreen(scenario: scenario, fromRandom: fromRandom);
default:
return _UnknownScenario(scenario: scenario);
}
}
}


class _UnknownScenario extends StatelessWidget {
final Scenario scenario;
const _UnknownScenario({required this.scenario});
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text(scenario.title)),
body: Center(
child: Text('Nieznany typ scenariusza: ${scenario.simulationType}'),
),
);
}
}
