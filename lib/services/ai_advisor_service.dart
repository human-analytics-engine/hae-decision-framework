// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/rule_model.dart';

class AiAdvisorService {
  // Karara özel 10 dinamik soruyu tek istekte üretir
  static Future<Map<int, Map<String, String>>> generateCustomQuestions({
    required String decisionTitle,
    required DecisionCategory category,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) return {};

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
      );

      final prompt = """
Sen Human Analytics Engine (HAE) ekosisteminin acımasız Sokratik Karar Sorgulayıcısısın.
Kullanıcı '${category.label}' kategorisinde şu kararı test ediyor: "$decisionTitle".

Bu kararı alan bir insanın kendini kandırmasını engellemek için, 10 kuralın her birine özel, son derece somut, sivri ve karara özel birer soru ve tuzak uyarısı üret.

Yanıtını SADECE ve SADECE aşağıdaki JSON array formatında döndür, markdown veya başka açıklama ekleme:
[
  {
    "id": 1,
    "question": "Bu karara özel, somut rakam veya tarih içeren sivri bir soru",
    "trap": "İnsanın düşeceği tipik avuntu veya kendini kandırma tuzağı"
  },
  ... (10'a kadar)
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
        
        // Markdown json taglarını temizle
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
      // Hata olursa boş döner, varsayılan insanileştirilmiş sorular çalışır
    }
    return {};
  }

  // Sonuç için sert reçete üretir
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
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
        );

        final prompt = """
Sen Human Analytics Engine Bilişsel Savunma Danışmanısın.
Kullanıcı '${category.label}' kategorisinde "$decisionTitle" kararını test etti.
- KÖR NOKTALAR (Hiç düşünülmemiş): ${failedRules.map((r) => r.title).join(", ")}
- YARIM PLANLAR (Sezgisel, yazılmamış): ${weakRules.map((r) => r.title).join(", ")}

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

    // Yerel akıllı reçete
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