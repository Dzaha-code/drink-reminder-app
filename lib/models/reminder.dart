import 'dart:convert';

class Reminder {
  Reminder({
    required this.id,
    required this.title,
    required this.time,
    this.enabled = true,
  });

  final String id;
  String title;
  DateTime time;
  bool enabled;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time.toIso8601String(),
      'enabled': enabled,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      time: DateTime.parse(map['time'] as String),
      enabled: map['enabled'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reminder.fromJson(String source) =>
      Reminder.fromMap(json.decode(source));
}
