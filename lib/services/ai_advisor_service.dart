// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rule_model.dart';

class AiAdvisorService {
  // Tablonda günlük 500 istek kotası olan modeller
  static const List<String> _models = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash',
  ];

  static Future<Map<int, Map<String, String>>> generateCustomQuestions({
    required String decisionTitle,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) return {};

    final prompt = """
Sen Human Analytics Engine Sokratik Karar Teftişçisisin.
Kullanıcı şu kararı test ediyor: "$decisionTitle".
Kararın bağlamını (yazılım, iş, ortaklık, kişisel vb.) kendi zekanla anla ve kategorize et.

10 Evrensel Kuralın her biri için bu karara özel, somut ve acımasız 1 soru ile insanın düşeceği 1 tipik avuntu/tuzak üret.
Zorlama tarihler sıkıştırma, mantık ve stratejiye odaklan.

SADECE aşağıdaki JSON formatında döndür:
[
  {
    "id": 1,
    "question": "Bu karara özel sivri soru",
    "trap": "Kendini kandırma tuzağı"
  }
]
""";

    for (String model in _models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

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
              "maxOutputTokens": 1200,
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
      } catch (_) {
        continue; // Bir modelde hata olursa listedeki diğer modele geçer
      }
    }
    return {};
  }

  static Future<String> generatePrescription({
    required String decisionTitle,
    required List<RuleModel> failedRules,
    required List<RuleModel> weakRules,
    String? apiKey,
  }) async {
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      final prompt = """
Sen Human Analytics Engine Bilişsel Savunma Danışmanısın.
Kullanıcı şu kararı test etti: "$decisionTitle".
Kararın türünü (yazılım, mimari, kariyer, yatırım) kendin anla ve O ALANIN diliyle konuş.
- KÖR NOKTALAR (Hiç düşünülmemiş): ${failedRules.map((r) => r.title).join(", ")}
- YARIM PLANLAR (Sezgisel): ${weakRules.map((r) => r.title).join(", ")}

Lütfen kullanıcıya acı gerçekleri yüzüne vuran, 3 maddelik çok sert ve bu karara özel bir eylem reçetesi yaz. Finans dışı konularda 'stop-loss' gibi alakasız borsa jargonu kullanma, konunun kendi diliyle konuş. Markdown formatında olsun.
""";

      for (String model in _models) {
        try {
          final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
          );

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
                "maxOutputTokens": 800,
              }
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return data['candidates'][0]['content']['parts'][0]['text'];
          }
        } catch (_) {
          continue;
        }
      }
    }

    return "### ⚠️ Bilişsel Kırılganlık Uyarısı\n\nBu kararda kritik kör noktalar tespit edildi. Lütfen en az bir tarafsız uzmana danışmadan ve başarısızlık halinde ne yapacağınızı netleştirmeden yola çıkmayın.";
  }
}