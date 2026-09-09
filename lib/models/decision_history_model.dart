// lib/models/decision_history_model.dart
import 'dart:convert';
import 'category_model.dart';

class DecisionHistory {
  final String title;
  final int score;
  final DateTime date;
  final List<int> failedRuleIds;
  final DecisionCategory category;

  DecisionHistory({
    required this.title,
    required this.score,
    required this.date,
    required this.failedRuleIds,
    this.category = DecisionCategory.personal,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'score': score,
      'date': date.toIso8601String(),
      'failedRuleIds': failedRuleIds,
      'category': category.name,
    };
  }

  factory DecisionHistory.fromMap(Map<String, dynamic> map) {
    DecisionCategory cat = DecisionCategory.personal;
    if (map['category'] != null) {
      cat = DecisionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DecisionCategory.personal,
      );
    }
    return DecisionHistory(
      title: map['title'] ?? '',
      score: map['score'] ?? 0,
      date: DateTime.parse(map['date']),
      failedRuleIds: List<int>.from(map['failedRuleIds'] ?? []),
      category: cat,
    );
  }

  String toJson() => json.encode(toMap());

  factory DecisionHistory.fromJson(String source) => DecisionHistory.fromMap(json.decode(source));
}