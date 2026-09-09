// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/rule_model.dart';

class AiAdvisorService {
  // Ultra hızlı Lite uç noktası
  static const String _model = 'gemini-2.5-flash-lite';

  static Future<Map<int, Map<String, String>>> generateCustomQuestions({
    required String decisionTitle,
    required DecisionCategory category,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) return {};

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
      );

      final prompt = """
Sen Human Analytics Engine Sokratik Karar Sorgulayıcısısın.
Kullanıcı '${category.label}' kategorisinde şu kararı test ediyor: "$decisionTitle".
Gereksiz yere her soruya spesifik tarih sıkıştırma; odak noktan mantık hataları, finansal kör noktalar, aşırı özgüven ve riskler olsun.

10 kuralın her biri için karara özel, tek cümlelik sivri bir soru ve insanın düşeceği bir tuzak üret.
SADECE aşağıdaki JSON formatında döndür:
[
  {
    "id": 1,
    "question": "Sivri ve somut soru",
    "trap": "Tipik kendini kandırma tuzağı"
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
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 1000, // Hız için token sınırlandı
          }
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
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
        );

        final prompt = """
Sen HAE Bilişsel Savunma Danışmanısın.
Kullanıcı '${category.label}' kategorisinde "$decisionTitle" kararını test etti.
- KÖR NOKTALAR: ${failedRules.map((r) => r.title).join(", ")}
- YARIM PLANLAR: ${weakRules.map((r) => r.title).join(", ")}

Lütfen lafı uzatmadan, doğrudan yüze vuran, uygulanabilir ve sert 3 maddelik bir acil eylem reçetesi yaz. Her cümlenin içine zorla tarih sıkıştırma. Markdown formatında olsun.
""";

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [{"text": prompt}]
              }
            ],
            "generationConfig": {
              "temperature": 0.8,
              "maxOutputTokens": 800, // Işık hızında dönsün
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } catch (_) {}
    }

    return "Kritik kör noktalar tespit edildi. Lütfen en az bir tarafsız hakeme danışmadan ve zarar limitinizi (Stop-Loss) sabitlemeden harekete geçmeyin.";
  }
}