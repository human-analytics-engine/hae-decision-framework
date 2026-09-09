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
    loadHistory();
  }

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

  void answerRule(int ruleId, bool passed) {
    final index = rules.indexWhere((r) => r.id == ruleId);
    if (index != -1) {
      rules[index].isPassed = passed;
      notifyListeners();
    }
  }

  int get calculateScore {
    int passedCount = rules.where((r) => r.isPassed).length;
    return (passedCount / rules.length * 100).toInt();
  }

  List<RuleModel> get failedRules {
    return rules.where((r) => !r.isPassed).toList();
  }

  // --- LOCAL STORAGE ---

  Future<void> saveCurrentDecision() async {
    final prefs = await SharedPreferences.getInstance();
    
    final newRecord = DecisionHistory(
      title: decisionTitle,
      score: calculateScore,
      date: DateTime.now(),
      failedRuleIds: failedRules.map((r) => r.id).toList(),
    );

    history.insert(0, newRecord);
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

  // --- EXPORT: MARKDOWN RAPORU OLUŞTURUCU ---
  String generateMarkdownReport({String? title, int? score, List<int>? failedIds}) {
    final reportTitle = title ?? decisionTitle;
    final reportScore = score ?? calculateScore;
    final failedList = failedIds ?? failedRules.map((r) => r.id).toList();

    StringBuffer sb = StringBuffer();
    sb.writeln("# 🧠 Bilişsel Karar Teftiş Raporu (HAE)");
    sb.writeln("**Karar:** $reportTitle");
    sb.writeln("**Sağlamlık Skoru:** %$reportScore");
    sb.writeln("**Tarih:** ${DateTime.now().toLocal()}\n");
    sb.writeln("---");
    sb.writeln("### 🛡️ 10 Kural Teftiş Sonuçları:\n");

    for (var rule in RulesData.universalRules) {
      bool passed = !failedList.contains(rule.id);
      sb.writeln("${passed ? '✅' : '❌'} **${rule.title}**: ${passed ? 'GEÇTİ' : 'BAŞARISIZ (Kırılganlık)'}");
      if (!passed) {
        sb.writeln("   > *Uyarı:* ${rule.description}");
      }
    }

    sb.writeln("\n---\n*Human Analytics Engine (HAE) - Decision Framework tarafından üretilmiştir.*");
    return sb.toString();
  }
}