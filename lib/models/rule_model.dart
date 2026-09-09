// lib/models/rule_model.dart

enum Stage { clearMind, testReality, survival }

enum HonestyLevel {
  blindSpot(0, 'Kör Noktam (Haklısın)', 'Bunu hiç düşünmedim veya görmezden geldim.'),
  intuitive(1, 'Sezgim Var', 'Kafamda kabataslak var ama yazılı/ölçülmüş değil.'),
  concrete(2, 'Somut Kanıtım Var', 'Yazılı, test edilmiş veya ölçülmüş planım var.'),
  exempt(-1, 'Muaf / Kapsam Dışı', 'Bu kararın doğası gereği bu kural geçersizdir.');

  final int points;
  final String label;
  final String description;
  const HonestyLevel(this.points, this.label, this.description);
}

class RuleModel {
  final int id;
  final Stage stage;
  final String title;
  final String concept;
  final String description;
  final String defaultQuestion;
  
  String? dynamicQuestion;
  String? dynamicTrap;
  
  HonestyLevel? selectedLevel;
  String? userNote;

  RuleModel({
    required this.id,
    required this.stage,
    required this.title,
    required this.concept,
    required this.description,
    required this.defaultQuestion,
    this.dynamicQuestion,
    this.dynamicTrap,
    this.selectedLevel,
    this.userNote,
  });

  String get activeQuestion => dynamicQuestion ?? defaultQuestion;
}