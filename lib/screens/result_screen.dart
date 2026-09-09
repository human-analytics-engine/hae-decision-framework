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
      failedRules: provider.blindSpotRules,
      weakRules: provider.intuitiveRules,
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
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF38BDF8)),
                  SizedBox(width: 8),
                  Text("AI Bilişsel Kurtarma Reçetesi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    final blinds = provider.blindSpotRules;
    final intuits = provider.intuitiveRules;

    Color scoreColor = score >= 80 ? const Color(0xFF10B981) : (score >= 50 ? Colors.orange : Colors.redAccent);

    return Scaffold(
      appBar: AppBar(title: const Text("Karar Teftiş Raporu"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text("Sağlamlık Skoru", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "%$score",
                    style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                  Text(
                    score >= 80 ? "Sistematik ve güvenli." : (score >= 50 ? "Riskli varsayımlar var!" : "Kritik bilişsel kör noktalar!"),
                    style: TextStyle(color: scoreColor, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Zafiyet Dağılımı", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _isLoadingAi ? null : () => _showAiPrescription(context),
                  icon: _isLoadingAi
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 16),
                  label: const Text("AI Reçetesi", style: TextStyle(color: Color(0xFF38BDF8))),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: [
                  if (blinds.isNotEmpty) ...[
                    const Text("🔴 KÖR NOKTALAR (Hiç Düşünülmemiş):", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...blinds.map((r) => _buildVulnerabilityCard(context, r, Colors.redAccent)),
                    const SizedBox(height: 16),
                  ],
                  if (intuits.isNotEmpty) ...[
                    const Text("🟡 YARIM PLANLAR (Sadece Sezgisel):", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...intuits.map((r) => _buildVulnerabilityCard(context, r, Colors.orange)),
                  ],
                  if (blinds.isEmpty && intuits.isEmpty) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("Tebrikler! Kararınız tüm 10 testi somut kanıtlarla geçti.", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),
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
                        const SnackBar(content: Text("Rapor panoya kopyalandı!")),
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

  Widget _buildVulnerabilityCard(BuildContext context, dynamic rule, Color color) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: color, size: 22),
        title: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(rule.activeQuestion, style: const TextStyle(fontSize: 12, height: 1.3)),
      ),
    );
  }
}