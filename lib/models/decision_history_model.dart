// lib/models/decision_history_model.dart
import 'dart:convert';

class DecisionHistory {
  final String title;
  final int score;
  final DateTime date;

  DecisionHistory({
    required this.title,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'score': score,
      'date': date.toIso8601String(),
    };
  }

  factory DecisionHistory.fromMap(Map<String, dynamic> map) {
    return DecisionHistory(
      title: map['title'],
      score: map['score'],
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DecisionHistory.fromJson(String source) => DecisionHistory.fromMap(json.decode(source));
}