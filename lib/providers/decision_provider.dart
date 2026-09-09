// lib/providers/decision_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rule_model.dart';
import '../core/rules_data.dart';
import '../models/decision_history_model.dart';

class DecisionProvider extends ChangeNotifier {
  String decisionTitle = "";
  List<RuleModel> rules = [];
  List<DecisionHistory> history = [];

  DecisionProvider() {
    loadHistory(); // Uygulama açıldığında geçmişi yükle
  }

  // Yeni test başlat
  void startNewDecision(String title) {
    decisionTitle = title;
    rules = RulesData.universalRules.map((rule) {
      return RuleModel(
        id: rule.id,
        stage: rule.stage,
        title: rule.title,
        description: rule.description,
        question: rule.question,
        isPassed: false,
      );
    }).toList();
    notifyListeners();
  }

  // Kural cevapla
  void answerRule(int ruleId, bool passed) {
    final index = rules.indexWhere((r) => r.id == ruleId);
    if (index != -1) {
      rules[index].isPassed = passed;
      notifyListeners();
    }
  }

  // Skor hesapla
  int get calculateScore {
    int passedCount = rules.where((r) => r.isPassed).length;
    return (passedCount / rules.length * 100).toInt();
  }

  // Başarısız kurallar
  List<RuleModel> get failedRules {
    return rules.where((r) => !r.isPassed).toList();
  }

  // --- LOCAL STORAGE İŞLEMLERİ ---

  Future<void> saveCurrentDecision() async {
    final prefs = await SharedPreferences.getInstance();
    
    final newRecord = DecisionHistory(
      title: decisionTitle,
      score: calculateScore,
      date: DateTime.now(),
    );

    history.insert(0, newRecord); // En başa ekle (en yeni)
    
    List<String> historyJsonList = history.map((h) => h.toJson()).toList();
    await prefs.setStringList('decision_history', historyJsonList);
    notifyListeners();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyJsonList = prefs.getStringList('decision_history');
    
    if (historyJsonList != null) {
      history = historyJsonList.map((jsonStr) => DecisionHistory.fromJson(jsonStr)).toList();
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('decision_history');
    history.clear();
    notifyListeners();
  }
}