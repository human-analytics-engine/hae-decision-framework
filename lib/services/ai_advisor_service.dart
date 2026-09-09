// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rule_model.dart';
import '../models/ai_provider.dart';

class AiAdvisorService {
  static Future<Map<int, Map<String, String>>> generateCustomQuestions({
    required String decisionTitle,
    required AiProvider provider,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) return {};

    final prompt = """
Sen Human Analytics Engine Sokratik Karar Teftişçisisin.
Kullanıcı şu kararı test ediyor: "$decisionTitle".
Kararın bağlamını kendi zekanla analiz et.

10 Evrensel Kuralın her biri için bu karara özel, somut ve vurucu 1 soru ile insanın düşeceği 1 tipik avuntu/tuzak üret.
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

    try {
      final text = await _executePrompt(provider, apiKey.trim(), prompt);
      if (text != null) {
        String cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
        List<dynamic> jsonList = jsonDecode(cleanJson);

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
    required List<RuleModel> failedRules,
    required List<RuleModel> weakRules,
    required List<RuleModel> exemptRules,
    required AiProvider provider,
    String? apiKey,
  }) async {
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      final prompt = """
Sen Human Analytics Engine Bilişsel Savunma Danışmanısın.
Kullanıcı şu kararı test etti: "$decisionTitle".
- KÖR NOKTALAR: ${failedRules.map((r) => r.title).join(", ")}
- YARIM PLANLAR: ${weakRules.map((r) => r.title).join(", ")}
- MUAF / KAPSAM DIŞI: ${exemptRules.map((r) => r.title).join(", ")}

Lütfen lafı uzatmadan, tam olarak aşağıdaki 3 bölüm formatında bir reçete yaz:

### 🎯 1. Bilişsel Röntgen (Teşhis)
(Kararın psikolojik ve stratejik analizini yapan, lafı dolandırmayan maksimum 2 paragraf)

### ⚡ 2. Kritik Eylem Adımları
(Tespit edilen kör noktalar için somut ve uygulanabilir maksimum 3 sert madde)

### ⏱️ 3. 48 Saatlik İlk Test
(Kullanıcının hemen yarın uygulayabileceği en küçük ve en acımasız gerçeklik testi)
""";

      try {
        final text = await _executePrompt(provider, apiKey.trim(), prompt);
        if (text != null && text.trim().isNotEmpty) return text.trim();
      } catch (_) {}
    }

    return "### 🎯 Bilişsel Röntgen\n\nBu kararda kritik kör noktalar tespit edildi. Lütfen en az bir tarafsız uzmana danışmadan ve başarısızlık kriterlerinizi sabitlemeden yola çıkmayın.";
  }

  // Çoklu Frontier Motor Yürütücüsü
  static Future<String?> _executePrompt(AiProvider provider, String key, String prompt) async {
    switch (provider) {
      case AiProvider.gemini:
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$key',
        );
        final res = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [{"text": prompt}]
              }
            ],
            "generationConfig": {"temperature": 0.7, "maxOutputTokens": 2048}
          }),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        break;

      case AiProvider.deepseek:
      case AiProvider.openai:
      case AiProvider.openrouter:
        String endpoint;
        String model = provider.defaultModel;

        if (provider == AiProvider.deepseek) {
          endpoint = 'https://api.deepseek.com/chat/completions';
        } else if (provider == AiProvider.openai) {
          endpoint = 'https://api.openai.com/v1/chat/completions';
        } else {
          endpoint = 'https://openrouter.ai/api/v1/chat/completions';
        }

        final res = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          },
          body: jsonEncode({
            "model": model,
            "messages": [
              {"role": "user", "content": prompt}
            ],
            "temperature": 0.7,
            "max_tokens": 2048,
          }),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          return data['choices'][0]['message']['content'];
        }
        break;

      case AiProvider.anthropic:
        final res = await http.post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            "model": provider.defaultModel,
            "max_tokens": 2048,
            "messages": [
              {"role": "user", "content": prompt}
            ]
          }),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          return data['content'][0]['text'];
        }
        break;
    }
    return null;
  }
}