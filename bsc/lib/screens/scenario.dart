import 'dart:convert';


class Scenario {
final String title;
final String type;
final String description;
final String icon;
final String simulationType; // 'sms' | 'call' | 'web'
final String? sound;
final bool vibration;
final String? content; // sms/web treść
final String? pageImage; // web: obrazek strony zamiast tekstu
final String? pageImageAlt;
final Map<String, dynamic>? a11y;
final Map<String, dynamic>? caller; // call
final String? dialogue; // call
final String? voice; // call spoken audio filename (e.g., mp3)
final String? onDeclineOutcome; // call
final List<Map<String, dynamic>> choices; // unified: from responses | options
final Map<String, dynamic> outcomes;
final String? difficulty; // 'easy'|'medium'|'hard'
final int weight; // for weighted random, default 1


Scenario({
required this.title,
required this.type,
required this.description,
required this.icon,
required this.simulationType,
this.sound,
required this.vibration,
this.content,
this.pageImage,
this.pageImageAlt,
this.a11y,
this.caller,
this.dialogue,
this.voice,
this.onDeclineOutcome,
required this.choices,
required this.outcomes,
this.difficulty,
this.weight = 1,
});


factory Scenario.fromJson(Map<String, dynamic> j) {
// unify choices from either 'responses' (sms/web) or 'options' (call)
final raw = (j['responses'] ?? j['options']) as List?;
final choices = raw?.map((e) => Map<String, dynamic>.from(e)).toList() ?? <Map<String, dynamic>>[];


return Scenario(
title: j['title'] ?? '',
type: j['type'] ?? '',
description: j['description'] ?? '',
icon: j['icon'] ?? 'info',
simulationType: j['simulationType'] ?? 'sms',
sound: j['sound'],
vibration: (j['vibration'] == true),
content: j['content'],
pageImage: j['pageImage'] ?? j['webImage'],
pageImageAlt: j['pageImageAlt'] ?? j['webImageAlt'],
a11y: j['a11y'] != null ? Map<String, dynamic>.from(j['a11y']) : null,
caller: j['caller'] != null ? Map<String, dynamic>.from(j['caller']) : null,
dialogue: j['dialogue'],
voice: j['voice'] ?? j['dialogueSound'],
onDeclineOutcome: j['onDeclineOutcome'],
choices: choices,
outcomes: Map<String, dynamic>.from(j['outcomes'] ?? {}),
difficulty: j['difficulty'],
weight: (j['weight'] is int) ? j['weight'] as int : 1,
);
}


static List<Scenario> listFromJsonString(String jsonStr) {
final arr = json.decode(jsonStr) as List<dynamic>;
return arr.map((e) => Scenario.fromJson(Map<String, dynamic>.from(e))).toList();
}
}
