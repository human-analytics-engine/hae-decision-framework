// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import '../services/ai_advisor_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecisionProvider>().saveCurrentDecision();
    });
  }

  void _showAiPrescription(BuildContext context) async {
    final provider = context.read<DecisionProvider>();
    setState(() => _isLoadingAi = true);

    final prescription = await AiAdvisorService.generatePrescription(
      decisionTitle: provider.decisionTitle,
      category: provider.selectedCategory,
      failedRules: provider.failedRules,
      apiKey: provider.geminiApiKey,
    );

    if (!mounted) return;
    setState(() => _isLoadingAi = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.psychology, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 8),
                  Text("AI Danışman Analizi", style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const Divider(height: 24),
              Text(prescription, style: const TextStyle(fontSize: 15, height: 1.6)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Anladım"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            const SizedBox(height: 24),
            if (failed.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("⚠️ Kırılganlıklar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _isLoadingAi ? null : () => _showAiPrescription(context),
                    icon: _isLoadingAi
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 18),
                    label: const Text("AI Reçetesi", style: TextStyle(color: Color(0xFF38BDF8))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                    label: const Text("Markdown Kopyala"),
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