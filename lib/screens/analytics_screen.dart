// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import '../core/rules_data.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final freq = provider.ruleFailureFrequency;

    return Scaffold(
      appBar: AppBar(title: const Text("Bilişsel Analitik")),
      body: provider.history.isEmpty
          ? const Center(child: Text("Analiz için henüz yeterli karar verisi yok."))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMetricCard(
                        context,
                        "Toplam Karar",
                        "${provider.totalDecisions}",
                        const Color(0xFF38BDF8),
                      ),
                      const SizedBox(width: 16),
                      _buildMetricCard(
                        context,
                        "Ortalama Skor",
                        "%${provider.averageScore}",
                        provider.averageScore >= 70 ? const Color(0xFF10B981) : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "En Sık Düştüğün Bilişsel Tuzaklar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bu kurallarda sürekli takılıyorsun; Sistem 2 filtrelerini buraya odakla.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: RulesData.universalRules.length,
                      itemBuilder: (context, index) {
                        final rule = RulesData.universalRules[index];
                        final failCount = freq[rule.id] ?? 0;
                        if (failCount == 0) return const SizedBox.shrink();

                        final percent = (failCount / provider.totalDecisions * 100).round();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
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
                                    child: Text(
                                      rule.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "$failCount kez ihlal (%$percent)",
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: failCount / provider.totalDecisions,
                                backgroundColor: Colors.white12,
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}