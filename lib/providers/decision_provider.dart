// lib/providers/decision_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rule_model.dart';
import '../core/rules_data.dart';
import '../models/decision_history_model.dart';
import '../models/ai_provider.dart';
import '../services/ai_advisor_service.dart';

class DecisionProvider extends ChangeNotifier {
  static const String appVersion = "v2.3.0";

  String decisionTitle = "";
  List<RuleModel> rules = [];
  List<DecisionHistory> history = [];
  String? apiKey;
  AiProvider selectedProvider = AiProvider.gemini;
  String? currentPrescription;
  bool isGeneratingQuestions = false;

  DecisionProvider() {
    loadSettingsAndHistory();
  }

  void setProviderAndKey(AiProvider provider, String key) async {
    selectedProvider = provider;
    apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_provider', provider.name);
    if (apiKey!.isEmpty) {
      await prefs.remove('ai_api_key');
      apiKey = null;
    } else {
      await prefs.setString('ai_api_key', apiKey!);
    }
    notifyListeners();
  }

  void setPrescription(String p, {String? targetTitle}) async {
    currentPrescription = p;
    final titleToMatch = targetTitle ?? decisionTitle;

    final index = history.indexWhere((h) => h.title == titleToMatch);
    if (index != -1) {
      final old = history[index];
      history[index] = DecisionHistory(
        title: old.title,
        score: old.score,
        date: old.date,
        failedRuleIds: old.failedRuleIds,
        prescription: p,
        ruleLevels: old.ruleLevels,
      );
      final prefs = await SharedPreferences.getInstance();
      List<String> historyJsonList = history.map((h) => h.toJson()).toList();
      await prefs.setStringList('decision_history', historyJsonList);
    }
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

    if (apiKey != null && apiKey!.isNotEmpty) {
      final customMap = await AiAdvisorService.generateCustomQuestions(
        decisionTitle: title,
        provider: selectedProvider,
        apiKey: apiKey,
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

  Map<Stage, int> get stageSuccessRates {
    Map<Stage, int> rates = {Stage.clearMind: 0, Stage.testReality: 0, Stage.survival: 0};
    if (rules.isEmpty) return rates;

    for (var stage in Stage.values) {
      final stageRules = rules.where((r) => r.stage == stage && r.selectedLevel != HonestyLevel.exempt).toList();
      if (stageRules.isEmpty) {
        rates[stage] = 100;
      } else {
        int earned = stageRules.fold(0, (sum, r) => sum + (r.selectedLevel?.points ?? 0));
        int max = stageRules.length * 2;
        rates[stage] = ((earned / max) * 100).round();
      }
    }
    return rates;
  }

  Future<void> saveCurrentDecision() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, String> levelsMap = {};
    for (var r in rules) {
      if (r.selectedLevel != null) {
        levelsMap[r.id.toString()] = r.selectedLevel!.name;
      }
    }

    final newRecord = DecisionHistory(
      title: decisionTitle,
      score: calculateScore,
      date: DateTime.now(),
      failedRuleIds: blindSpotRules.map((r) => r.id).toList(),
      prescription: currentPrescription,
      ruleLevels: levelsMap,
    );

    history.insert(0, newRecord);
    List<String> historyJsonList = history.map((h) => h.toJson()).toList();
    await prefs.setStringList('decision_history', historyJsonList);
    notifyListeners();
  }

  Future<void> loadSettingsAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final provName = prefs.getString('ai_provider');
    if (provName != null) {
      selectedProvider = AiProvider.values.firstWhere(
        (e) => e.name == provName,
        orElse: () => AiProvider.gemini,
      );
    }
    apiKey = prefs.getString('ai_api_key') ?? prefs.getString('gemini_api_key');

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
    sb.writeln("# 🧠 Bilişsel Karar Teftiş Raporu (HAE $appVersion)");
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