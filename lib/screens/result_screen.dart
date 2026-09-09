// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecisionProvider>().saveCurrentDecision();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final score = provider.calculateScore;
    final failed = provider.failedRules;

    Color scoreColor = score >= 80 ? const Color(0xFF10B981) : (score >= 50 ? Colors.orange : Colors.redAccent);

    return Scaffold(
      appBar: AppBar(title: const Text("Karar Raporu"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text("Sağlamlık Skoru", style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    "%$score",
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                  Text(
                    score >= 80 ? "Sistematik ve güvenli." : "Bilişsel zaaflar tespit edildi!",
                    style: TextStyle(color: scoreColor, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (failed.isNotEmpty) ...[
              const Text("⚠️ Zayıf Noktalar (Kırılganlıklar)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: failed.length,
                  itemBuilder: (context, index) {
                    final rule = failed[index];
                    return Card(
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        title: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(rule.description),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text("Tebrikler! Kararınız tüm testleri geçti.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text("Raporu Kopyala"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF38BDF8)),
                      foregroundColor: const Color(0xFF38BDF8),
                    ),
                    onPressed: () {
                      final md = provider.generateMarkdownReport();
                      Clipboard.setData(ClipboardData(text: md));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Markdown raporu panoya kopyalandı!")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tamamla"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}