// lib/models/rule_model.dart

enum Stage { clearMind, testReality, survival }

class RuleModel {
  final int id;
  final Stage stage;
  final String title;
  final String description;
  final String question; // Kullanıcıya sorulacak test sorusu
  bool isPassed; // Kullanıcı bu kuraldan geçti mi?

  RuleModel({
    required this.id,
    required this.stage,
    required this.title,
    required this.description,
    required this.question,
    this.isPassed = false,
  });
}