// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import '../core/rules_data.dart';
import '../models/rule_model.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final freq = provider.ruleFailureFrequency;
    final stageRates = provider.stageSuccessRates;

    String archetype = "Analitik Stratejist";
    String archetypeDesc = "Düşünceleriniz ve savunma refleksleriniz dengeli bir dağılım gösteriyor.";

    if (provider.history.isNotEmpty) {
      if ((freq[8] ?? 0) + (freq[1] ?? 0) >= 2) {
        archetype = "Gözüpek / İdealist Mühendis";
        archetypeDesc = "Fikir üretme tutkunuz çok yüksek, ancak 'Yedek Paraşüt' ve 'Geri Dönüş Çizgisi' refleksleriniz riskli derecede zayıf.";
      } else if ((freq[3] ?? 0) + (freq[4] ?? 0) >= 2) {
        archetype = "Aşırı İyimser Kurucu";
        archetypeDesc = "Kendi fikrinize çabuk aşık oluyor, 'Fikri Katletme' ve 'Tarafsız Hakem' adımlarını ihmal ediyorsunuz.";
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bilişsel Röntgen & Analitik")),
      body: provider.history.isEmpty
          ? const Center(child: Text("Analiz için henüz yeterli karar verisi yok."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Üst Metrikler
                  Row(
                    children: [
                      _buildMetricCard(context, "Toplam Karar", "${provider.totalDecisions}", const Color(0xFF38BDF8)),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        context,
                        "Ortalama Skor",
                        "%${provider.averageScore}",
                        provider.averageScore >= 70 ? const Color(0xFF10B981) : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Bilişsel Arketip Kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.fingerprint, color: Color(0xFF38BDF8), size: 22),
                            SizedBox(width: 8),
                            Text("Bilişsel Arketipiniz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(archetype, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                        const SizedBox(height: 6),
                        Text(archetypeDesc, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. 3 Aşama Başarı Oranı
                  const Text("Savunma Katmanları Başarısı", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildStageBar("AŞAMA 1: ZİHNİ TEMİZLE", stageRates[Stage.clearMind] ?? 0, const Color(0xFF38BDF8)),
                  const SizedBox(height: 10),
                  _buildStageBar("AŞAMA 2: GERÇEKLİKLE YÜZLEŞ", stageRates[Stage.testReality] ?? 0, Colors.orange),
                  const SizedBox(height: 10),
                  _buildStageBar("AŞAMA 3: KORUNMA & HAYATTA KALMA", stageRates[Stage.survival] ?? 0, const Color(0xFF10B981)),

                  const SizedBox(height: 28),

                  // 4. En Sık İhlal Edilen Kurallar
                  const Text("En Sık Düştüğün Bilişsel Tuzaklar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Sistem 2 kalkanlarınızı bu kurallara daha fazla odaklamalısınız.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: RulesData.universalRules.length,
                    itemBuilder: (context, index) {
                      final rule = RulesData.universalRules[index];
                      final failCount = freq[rule.id] ?? 0;
                      if (failCount == 0) return const SizedBox.shrink();

                      final percent = (failCount / provider.totalDecisions * 100).round();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                Text(
                                  "$failCount kez ihlal (%$percent)",
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: failCount / provider.totalDecisions,
                              backgroundColor: Colors.white12,
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStageBar(String label, int percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              Text("%$percentage", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}