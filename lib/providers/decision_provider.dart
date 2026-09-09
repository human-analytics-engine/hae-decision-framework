// lib/providers/decision_provider.dart
import 'package:flutter/material.dart';
import '../models/rule_model.dart';
import '../core/rules_data.dart';

class DecisionProvider extends ChangeNotifier {
  String decisionTitle = "";
  List<RuleModel> rules = [];

  // Yeni bir karar testi başlat
  void startNewDecision(String title) {
    decisionTitle = title;
    // Her yeni kararda statik kuralların yeni bir kopyasını alıyoruz
    rules = RulesData.universalRules.map((rule) {
      return RuleModel(
        id: rule.id,
        stage: rule.stage,
        title: rule.title,
        description: rule.description,
        question: rule.question,
        isPassed: false, // Başlangıçta hepsi false
      );
    }).toList();
    notifyListeners();
  }

  // Kullanıcı bir kuralı cevapladığında
  void answerRule(int ruleId, bool passed) {
    final index = rules.indexWhere((r) => r.id == ruleId);
    if (index != -1) {
      rules[index].isPassed = passed;
      notifyListeners();
    }
  }

  // Sonuç skoru hesaplama
  int get calculateScore {
    int passedCount = rules.where((r) => r.isPassed).length;
    return (passedCount / rules.length * 100).toInt();
  }

  // Geçilemeyen (Zayıf) kuralları getir
  List<RuleModel> get failedRules {
    return rules.where((r) => !r.isPassed).toList();
  }
}