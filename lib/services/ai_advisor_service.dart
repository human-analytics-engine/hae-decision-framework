// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rule_model.dart';

class AiAdvisorService {
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
Kararın bağlamını (yazılım, iş, ortaklık, açık kaynak, kişisel vb.) kendi zekanla analiz et.

10 Evrensel Kuralın her biri için karara özel, somut ve vurucu 1 soru ile insanın düşeceği 1 tipik avuntu/tuzak üret.
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
              "maxOutputTokens": 1500,
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
        continue;
      }
    }
    return {};
  }

  static Future<String> generatePrescription({
    required String decisionTitle,
    required List<RuleModel> failedRules,
    required List<RuleModel> weakRules,
    required List<RuleModel> exemptRules,
    String? apiKey,
  }) async {
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      final prompt = """
Sen Human Analytics Engine Bilişsel Savunma Danışmanısın.
Kullanıcı şu kararı test etti: "$decisionTitle".
- KÖR NOKTALAR (Yüzleşilen Zaaflar): ${failedRules.map((r) => r.title).join(", ")}
- YARIM PLANLAR (Sezgisel): ${weakRules.map((r) => r.title).join(", ")}
- MUAF / KAPSAM DIŞI: ${exemptRules.map((r) => r.title).join(", ")}

Lütfen metni yarıda kesmeyecek şekilde, DERLİ TOPLU, OKUNAKLI ve tam olarak aşağıdaki 3 blok formatında bir reçete yaz:

### 🎯 1. Bilişsel Röntgen (Teşhis)
(Kararın psikolojik ve stratejik analizini yapan, lafı dolandırmayan maksimum 2 paragraf)

### ⚡ 2. Kritik Eylem Adımları
(Tespit edilen kör noktalar için somut ve uygulanabilir maksimum 3 sert madde)

### ⏱️ 3. 48 Saatlik İlk Test
(Kullanıcının hemen yarın uygulayabileceği en küçük ve en acımasız gerçeklik testi)
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
                "temperature": 0.75,
                "maxOutputTokens": 2048,
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

    return "### 🎯 Bilişsel Röntgen\n\nBu kararda kritik kör noktalar tespit edildi. Lütfen en az bir tarafsız uzmana danışmadan ve başarısızlık kriterlerinizi sabitlemeden yola çıkmayın.";
  }
}