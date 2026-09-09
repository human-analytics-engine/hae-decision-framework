// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/rule_model.dart';

class AiAdvisorService {
  static Future<Map<int, Map<String, String>>> generateCustomQuestions({
    required String decisionTitle,
    required DecisionCategory category,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) return {};

    final now = DateTime.now();
    final todayStr = "${now.day}.${now.month}.${now.year}";

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
      );

      final prompt = """
Sen Human Analytics Engine (HAE) ekosisteminin acımasız Sokratik Karar Sorgulayıcısısın.
Bugünün tarihi: $todayStr. Soracağın hedef ve vadeleri BUGÜNDEN SONRAKİ ileri tarihler olarak ver (asla geçmiş tarih verme).

Kullanıcı '${category.label}' kategorisinde şu kararı test ediyor: "$decisionTitle".

Bu kararı alan bir insanın kendini kandırmasını engellemek için, 10 kuralın her birine özel, son derece somut, rakam veya hedef tarih içeren sivri birer soru ve tuzak uyarısı üret.

Yanıtını SADECE aşağıdaki JSON array formatında döndür:
[
  {
    "id": 1,
    "question": "Somut ve sivri soru",
    "trap": "İnsanın düşeceği tipik kendini kandırma tuzağı"
  }
]
""";

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        List<dynamic> jsonList = jsonDecode(text);

        Map<int, Map<String, String>> result = {};
        for (var item in jsonList) {
          result[item['id']] = {
            'question': item['question'].toString(),
            'trap': item['trap'].toString(),
          };
        }
        return result;
      }
    } catch (_) {}
    return {};
  }

  static Future<String> generatePrescription({
    required String decisionTitle,
    required DecisionCategory category,
    required List<RuleModel> failedRules,
    required List<RuleModel> weakRules,
    String? apiKey,
  }) async {
    final now = DateTime.now();
    final todayStr = "${now.day}.${now.month}.${now.year}";

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
        );

        final prompt = """
Sen Human Analytics Engine Bilişsel Savunma Danışmanısın.
Bugünün tarihi: $todayStr.
Kullanıcı '${category.label}' kategorisinde "$decisionTitle" kararını test etti.
- KÖR NOKTALAR: ${failedRules.map((r) => r.title).join(", ")}
- YARIM PLANLAR: ${weakRules.map((r) => r.title).join(", ")}

Lütfen kullanıcıya acı gerçekleri yüzüne vuran, 3 maddelik çok sert ve uygulanabilir bir acil eylem planı (reçete) yaz. Markdown formatında olsun.
""";

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [{"text": prompt}]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } catch (_) {}
    }

    StringBuffer sb = StringBuffer();
    sb.writeln("### 🤖 Bilişsel Kurtarma Reçetesi ($decisionTitle)");
    sb.writeln("*Tespit edilen ${failedRules.length} kritik kör nokta için acil adımlar:*\n");
    for (var r in failedRules) {
      sb.writeln("**📌 ${r.title}:**");
      sb.writeln("→ ${r.description} kuralını bu karara derhal dahil et; aksi halde kendini kandırıyorsun.\n");
    }
    return sb.toString();
  }
}