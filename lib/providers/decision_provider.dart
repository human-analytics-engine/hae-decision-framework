// lib/providers/decision_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rule_model.dart';
import '../core/rules_data.dart';
import '../models/decision_history_model.dart';
import '../services/ai_advisor_service.dart';

class DecisionProvider extends ChangeNotifier {
  String decisionTitle = "";
  List<RuleModel> rules = [];
  List<DecisionHistory> history = [];
  String? geminiApiKey;
  String? currentPrescription;
  bool isGeneratingQuestions = false;

  DecisionProvider() {
    loadSettingsAndHistory();
  }

  void setApiKey(String key) async {
    geminiApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    notifyListeners();
  }

  void setPrescription(String p) {
    currentPrescription = p;
    notifyListeners();
  }

  Future<void> startNewDecision(String title) async {
    decisionTitle = title;
    currentPrescription = null;
    isGeneratingQuestions = true;
    notifyListeners();

    rules = RulesData.universalRules.map((r) => RuleModel(
      id: r.id,
      stage: r.stage,
      title: r.title,
      concept: r.concept,
      description: r.description,
      defaultQuestion: r.defaultQuestion,
    )).toList();

    if (geminiApiKey != null && geminiApiKey!.isNotEmpty) {
      final customMap = await AiAdvisorService.generateCustomQuestions(
        decisionTitle: title,
        apiKey: geminiApiKey,
      );

      if (customMap.isNotEmpty) {
        for (var rule in rules) {
          if (customMap.containsKey(rule.id)) {
            rule.dynamicQuestion = customMap[rule.id]?['question'];
            rule.dynamicTrap = customMap[rule.id]?['trap'];
          }
        }
      }
    }

    isGeneratingQuestions = false;
    notifyListeners();
  }

  void answerRule(int ruleId, HonestyLevel level, {String? note}) {
    final index = rules.indexWhere((r) => r.id == ruleId);
    if (index != -1) {
      rules[index].selectedLevel = level;
      if (note != null) rules[index].userNote = note;
      notifyListeners();
    }
  }

  int get calculateScore {
    final activeRules = rules.where((r) => r.selectedLevel != HonestyLevel.exempt).toList();
    if (activeRules.isEmpty) return 100;

    int totalPoints = activeRules.fold(0, (sum, r) => sum + (r.selectedLevel?.points ?? 0));
    int maxPoints = activeRules.length * 2;
    return ((totalPoints / maxPoints) * 100).round();
  }

  List<RuleModel> get blindSpotRules => rules.where((r) => r.selectedLevel == HonestyLevel.blindSpot).toList();
  List<RuleModel> get intuitiveRules => rules.where((r) => r.selectedLevel == HonestyLevel.intuitive).toList();
  List<RuleModel> get concreteRules => rules.where((r) => r.selectedLevel == HonestyLevel.concrete).toList();
  List<RuleModel> get exemptRules => rules.where((r) => r.selectedLevel == HonestyLevel.exempt).toList();
  List<RuleModel> get failedRules => blindSpotRules;

  int get totalDecisions => history.length;
  int get averageScore {
    if (history.isEmpty) return 0;
    int total = history.fold(0, (sum, item) => sum + item.score);
    return (total / history.length).round();
  }

  Map<int, int> get ruleFailureFrequency {
    Map<int, int> freq = {};
    for (var h in history) {
      for (var id in h.failedRuleIds) {
        freq[id] = (freq[id] ?? 0) + 1;
      }
    }
    return freq;
  }

  Future<void> saveCurrentDecision() async {
    final prefs = await SharedPreferences.getInstance();
    final newRecord = DecisionHistory(
      title: decisionTitle,
      score: calculateScore,
      date: DateTime.now(),
      failedRuleIds: blindSpotRules.map((r) => r.id).toList(),
      prescription: currentPrescription,
    );

    history.insert(0, newRecord);
    List<String> historyJsonList = history.map((h) => h.toJson()).toList();
    await prefs.setStringList('decision_history', historyJsonList);
    notifyListeners();
  }

  Future<void> loadSettingsAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    geminiApiKey = prefs.getString('gemini_api_key');
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

  String generateMarkdownReport({String? title, int? score, List<int>? failedIds}) {
    final reportTitle = title ?? decisionTitle;
    final reportScore = score ?? calculateScore;

    StringBuffer sb = StringBuffer();
    sb.writeln("# 🧠 Bilişsel Karar Teftiş Raporu (HAE v2.1)");
    sb.writeln("**Karar:** $reportTitle");
    sb.writeln("**Sağlamlık Skoru:** %$reportScore");
    sb.writeln("**Tarih:** ${DateTime.now().toLocal()}\n");
    sb.writeln("---");
    sb.writeln("### 🛡️ 10 Kural Dökümü:\n");

    for (var rule in rules) {
      String icon;
      switch (rule.selectedLevel) {
        case HonestyLevel.concrete:
          icon = '🟢';
          break;
        case HonestyLevel.intuitive:
          icon = '🟡';
          break;
        case HonestyLevel.blindSpot:
          icon = '🔴';
          break;
        case HonestyLevel.exempt:
          icon = '⚪';
          break;
        default:
          icon = '⚪';
      }

      sb.writeln("$icon **${rule.title}** (${rule.concept})");
      sb.writeln("   *Soru:* ${rule.activeQuestion}");
      sb.writeln("   *Durum:* ${rule.selectedLevel?.label ?? 'Cevaplanmadı'}");
      sb.writeln();
    }

    if (currentPrescription != null && currentPrescription!.isNotEmpty) {
      sb.writeln("---\n");
      sb.writeln("## 🤖 AI Bilişsel Kurtarma Reçetesi\n");
      sb.writeln(currentPrescription);
      sb.writeln();
    }

    sb.writeln("\n---\n*Human Analytics Engine (HAE) - Socratic Decision Lab tarafından üretilmiştir.*");
    return sb.toString();
  }
}