// lib/models/decision_history_model.dart
import 'dart:convert';

class DecisionHistory {
  final String title;
  final int score;
  final DateTime date;
  final List<int> failedRuleIds;
  final String? prescription;
  final Map<String, String>? ruleLevels; // Kural ID -> HonestyLevel.name

  DecisionHistory({
    required this.title,
    required this.score,
    required this.date,
    required this.failedRuleIds,
    this.prescription,
    this.ruleLevels,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'score': score,
      'date': date.toIso8601String(),
      'failedRuleIds': failedRuleIds,
      'prescription': prescription,
      'ruleLevels': ruleLevels,
    };
  }

  factory DecisionHistory.fromMap(Map<String, dynamic> map) {
    return DecisionHistory(
      title: map['title'] ?? '',
      score: map['score'] ?? 0,
      date: DateTime.parse(map['date']),
      failedRuleIds: List<int>.from(map['failedRuleIds'] ?? []),
      prescription: map['prescription'],
      ruleLevels: map['ruleLevels'] != null ? Map<String, String>.from(map['ruleLevels']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DecisionHistory.fromJson(String source) => DecisionHistory.fromMap(json.decode(source));
}