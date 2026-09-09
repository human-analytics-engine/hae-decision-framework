// lib/services/ai_advisor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/rule_model.dart';

class AiAdvisorService {
  static Future<String> generatePrescription({
    required String decisionTitle,
    required DecisionCategory category,
    required List<RuleModel> failedRules,
    String? apiKey,
  }) async {
    if (failedRules.isEmpty) {
      return "Tebrikler! Kararınız tüm bilişsel savunma testlerini geçti. Herhangi bir kritik kırılganlık tespit edilmedi.";
    }

    // Eğer kullanıcı Gemini API anahtarı girdiyse gerçek LLM'e gitsin
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
        );

        final prompt = """
Sen Human Analytics Engine (HAE) ekosisteminin Bilişsel Savunma Danışmanısın.
Kullanıcı '${category.label}' kategorisinde şu kararı test etti: "$decisionTitle".
Karar şu 10 Evrensel Kural testlerinden kaldı:
${failedRules.map((r) => "- ${r.title}: ${r.description}").join("\n")}

Lütfen kullanıcıya bu kararı batırmaması ve kendini kandırmaması için kısa, sert, doğrudan ve uygulanabilir 3 maddelik acil eylem planı (reçete) yaz. Markdown formatında olsun.
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
      } catch (_) {
        // Hata durumunda yerel motora geri düşer
      }
    }

    // API anahtarı yoksa akıllı yerel bilişsel motor devreye girer
    StringBuffer sb = StringBuffer();
    sb.writeln("### 🤖 Bilişsel Kurtarma Reçetesi ($decisionTitle)");
    sb.writeln("*Tespit edilen ${failedRules.length} kritik zaafiyet için acil adımlar:*\n");

    for (var r in failedRules) {
      sb.writeln("**📌 ${r.title} İhlali İçin:**");
      if (r.id == 2) {
        sb.writeln("→ Benzer durumdaki 5 vakanın başarısızlık nedenlerini analiz etmeden sermaye veya vakit bağlama.");
      } else if (r.id == 3) {
        sb.writeln("→ Projeyi en sert eleştirecek bir 'Şeytanın Avukatı' bulup fikrini çürütmesini iste.");
      } else if (r.id == 4) {
        sb.writeln("→ Karardan hiçbir kişisel veya finansal çıkarı olmayan tarafsız bir hakeme danış.");
      } else if (r.id == 8) {
        sb.writeln("→ Bütçeni veya takvimini en az %30 esnet; hata toleransı bırakmadan yola çıkma.");
      } else {
        sb.writeln("→ ${r.description} prensibini kararına derhal entegre et.");
      }
      sb.writeln();
    }
    return sb.toString();
  }
}