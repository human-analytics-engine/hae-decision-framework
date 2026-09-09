// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import '../models/rule_model.dart';
import '../services/ai_advisor_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoadingAi = false;
  int _activeFilter = 0; // 0: Tümü, 1: Kör Noktalar, 2: Yarım Planlar, 3: Muaf

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecisionProvider>().saveCurrentDecision();
      _fetchAiPrescriptionAuto();
    });
  }

  void _fetchAiPrescriptionAuto() async {
    final provider = context.read<DecisionProvider>();
    if (provider.currentPrescription != null) return;

    setState(() => _isLoadingAi = true);
    final prescription = await AiAdvisorService.generatePrescription(
      decisionTitle: provider.decisionTitle,
      failedRules: provider.blindSpotRules,
      weakRules: provider.intuitiveRules,
      exemptRules: provider.exemptRules,
      apiKey: provider.geminiApiKey,
    );

    if (!mounted) return;
    provider.setPrescription(prescription);
    setState(() => _isLoadingAi = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final score = provider.calculateScore;
    final blinds = provider.blindSpotRules;
    final intuits = provider.intuitiveRules;
    final exempts = provider.exemptRules;

    Color scoreColor = score >= 80 
        ? const Color(0xFF10B981) 
        : (score >= 50 ? Colors.orange : Colors.redAccent);

    List<RuleModel> displayedRules;
    switch (_activeFilter) {
      case 1:
        displayedRules = blinds;
        break;
      case 2:
        displayedRules = intuits;
        break;
      case 3:
        displayedRules = exempts;
        break;
      default:
        displayedRules = provider.rules;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bilişsel Teftiş Raporu"), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Üst Skor Kartı
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text("Sağlamlık Skoru", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      "%$score",
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: scoreColor),
                    ),
                    Text(
                      score >= 80 ? "Sistematik ve güvenli." : (score >= 50 ? "Riskli varsayımlar var!" : "Kritik bilişsel kör noktalar!"),
                      style: TextStyle(color: scoreColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. AI Reçetesi Kartı (Doğrudan Ekranda)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 20),
                          SizedBox(width: 8),
                          Text("AI Kurtarma Reçetesi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (_isLoadingAi)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      else if (provider.currentPrescription != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16, color: Color(0xFF38BDF8)),
                          tooltip: "Reçeteyi Kopyala",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: provider.currentPrescription!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("AI Reçetesi panoya kopyalandı!")),
                            );
                          },
                        ),
                    ],
                  ),
                  const Divider(height: 20),
                  if (_isLoadingAi)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text("Gemini 3.5 reçeteyi hazırlıyor...", style: TextStyle(color: Colors.grey))),
                    )
                  else
                    Text(
                      provider.currentPrescription ?? "Reçete oluşturulamadı.",
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Filtre Çipleri
            const Text("Kural Dökümü", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(0, "Tümü (${provider.rules.length})"),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, "Kör Noktalar (${blinds.length})", color: Colors.redAccent),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, "Yarım Planlar (${intuits.length})", color: Colors.orange),
                  const SizedBox(width: 8),
                  _buildFilterChip(3, "Muaf (${exempts.length})", color: Colors.blueGrey),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Kurallar Listesi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedRules.length,
              itemBuilder: (context, index) {
                final rule = displayedRules[index];
                Color itemColor;
                IconData itemIcon;
                switch (rule.selectedLevel) {
                  case HonestyLevel.concrete:
                    itemColor = const Color(0xFF10B981);
                    itemIcon = Icons.check_circle_outline;
                    break;
                  case HonestyLevel.intuitive:
                    itemColor = Colors.orange;
                    itemIcon = Icons.help_outline;
                    break;
                  case HonestyLevel.blindSpot:
                    itemColor = Colors.redAccent;
                    itemIcon = Icons.cancel_outlined;
                    break;
                  case HonestyLevel.exempt:
                    itemColor = Colors.blueGrey;
                    itemIcon = Icons.remove_circle_outline;
                    break;
                  default:
                    itemColor = Colors.grey;
                    itemIcon = Icons.circle_outlined;
                }

                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(itemIcon, color: itemColor, size: 22),
                    title: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(rule.activeQuestion, style: const TextStyle(fontSize: 12, height: 1.3)),
                    trailing: Text(
                      rule.selectedLevel?.label ?? "",
                      style: TextStyle(color: itemColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text("Tüm Raporu Kopyala"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF38BDF8)),
                      foregroundColor: const Color(0xFF38BDF8),
                    ),
                    onPressed: () {
                      final md = provider.generateMarkdownReport();
                      Clipboard.setData(ClipboardData(text: md));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tüm rapor panoya kopyalandı!")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
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

  Widget _buildFilterChip(int index, String label, {Color? color}) {
    final isSelected = _activeFilter == index;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: (color ?? const Color(0xFF38BDF8)).withValues(alpha: 0.25),
      labelStyle: TextStyle(
        color: isSelected ? (color ?? const Color(0xFF38BDF8)) : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _activeFilter = index),
    );
  }
}