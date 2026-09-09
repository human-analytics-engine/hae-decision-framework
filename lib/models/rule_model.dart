// lib/models/rule_model.dart

enum Stage { clearMind, testReality, survival }

enum HonestyLevel {
  blindSpot(0, 'Kör Noktam', 'Bunu hiç düşünmedim veya görmezden geldim.'),
  intuitive(1, 'Sezgim Var', 'Kafamda kabataslak var ama yazılı/ölçülmüş değil.'),
  concrete(2, 'Somut Kanıtım Var', 'Yazılı, test edilmiş veya ölçülmüş planım var.');

  final int points;
  final String label;
  final String description;
  const HonestyLevel(this.points, this.label, this.description);
}

class RuleModel {
  final int id;
  final Stage stage;
  final String title;
  final String concept; // Akademik/orijinal adı
  final String description;
  final String defaultQuestion;
  
  // AI tarafından bu karara özel dinamik üretilen alanlar:
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