import 'dart:convert';

class Tracker {
  final String id;
  String name;
  String emoji;
  DateTime startDate;
  int bestStreak;
  String? reminderTime; // "HH:mm" or null
  DateTime createdAt;
  int colorIndex;

  Tracker({
    required this.id,
    required this.name,
    this.emoji = '🎯',
    required this.startDate,
    this.bestStreak = 0,
    this.reminderTime,
    this.colorIndex = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get daysElapsed {
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(start).inDays;
  }

  void updateBestStreak() {
    if (daysElapsed > bestStreak) {
      bestStreak = daysElapsed;
    }
  }

  void reset() {
    updateBestStreak();
    startDate = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'startDate': startDate.toIso8601String(),
        'bestStreak': bestStreak,
        'reminderTime': reminderTime,
        'createdAt': createdAt.toIso8601String(),
        'colorIndex': colorIndex,
      };

  factory Tracker.fromJson(Map<String, dynamic> json) => Tracker(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'] ?? '🎯',
        startDate: DateTime.parse(json['startDate']),
        bestStreak: json['bestStreak'] ?? 0,
        reminderTime: json['reminderTime'],
        createdAt: DateTime.parse(json['createdAt']),
        colorIndex: json['colorIndex'] ?? 0,
      );

  static List<Tracker> listFromJson(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => Tracker.fromJson(e)).toList();
  }

  static String listToJson(List<Tracker> trackers) {
    return jsonEncode(trackers.map((t) => t.toJson()).toList());
  }
}

class Profile {
  String name;
  String? photoPath;

  Profile({this.name = '', this.photoPath});

  Map<String, dynamic> toJson() => {
        'name': name,
        'photoPath': photoPath,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: json['name'] ?? '',
        photoPath: json['photoPath'],
      );

  String toJsonString() => jsonEncode(toJson());

  factory Profile.fromJsonString(String jsonStr) =>
      Profile.fromJson(jsonDecode(jsonStr));
}
