// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import '../models/decision_history_model.dart';
import '../models/rule_model.dart';
import '../core/rules_data.dart';
import '../services/ai_advisor_service.dart';

class ResultScreen extends StatefulWidget {
  final DecisionHistory? historyRecord;

  const ResultScreen({super.key, this.historyRecord});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoadingAi = false;
  int _activeFilter = 0;

  @override
  void initState() {
    super.initState();
    if (widget.historyRecord == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DecisionProvider>().saveCurrentDecision();
        _fetchAiPrescriptionAuto();
      });
    }
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

  void _generatePrescriptionForHistory(String title, List<RuleModel> blinds, List<RuleModel> intuits, List<RuleModel> exempts) async {
    final provider = context.read<DecisionProvider>();
    setState(() => _isLoadingAi = true);

    final prescription = await AiAdvisorService.generatePrescription(
      decisionTitle: title,
      failedRules: blinds,
      weakRules: intuits,
      exemptRules: exempts,
      apiKey: provider.geminiApiKey,
    );

    if (!mounted) return;
    provider.setPrescription(prescription, targetTitle: title);
    setState(() => _isLoadingAi = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final isHistory = widget.historyRecord != null;

    final String title = isHistory ? widget.historyRecord!.title : provider.decisionTitle;
    final int score = isHistory ? widget.historyRecord!.score : provider.calculateScore;
    
    // Geçmiş kayıtlarda güncellenen reçeteyi provider'dan dinamik oku
    String? prescription;
    if (isHistory) {
      final match = provider.history.firstWhere((h) => h.title == title, orElse: () => widget.historyRecord!);
      prescription = match.prescription;
    } else {
      prescription = provider.currentPrescription;
    }

    List<RuleModel> allRules;
    if (isHistory) {
      allRules = RulesData.universalRules.map((baseRule) {
        HonestyLevel level = HonestyLevel.concrete;
        if (widget.historyRecord!.ruleLevels != null) {
          final levelName = widget.historyRecord!.ruleLevels![baseRule.id.toString()];
          level = HonestyLevel.values.firstWhere((e) => e.name == levelName, orElse: () => HonestyLevel.concrete);
        } else if (widget.historyRecord!.failedRuleIds.contains(baseRule.id)) {
          level = HonestyLevel.blindSpot;
        }
        return RuleModel(
          id: baseRule.id,
          stage: baseRule.stage,
          title: baseRule.title,
          concept: baseRule.concept,
          description: baseRule.description,
          defaultQuestion: baseRule.defaultQuestion,
          selectedLevel: level,
        );
      }).toList();
    } else {
      allRules = provider.rules;
    }

    final blinds = allRules.where((r) => r.selectedLevel == HonestyLevel.blindSpot).toList();
    final intuits = allRules.where((r) => r.selectedLevel == HonestyLevel.intuitive).toList();
    final exempts = allRules.where((r) => r.selectedLevel == HonestyLevel.exempt).toList();

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
        displayedRules = allRules;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isHistory ? "Kayıtlı Teftiş Raporu" : "Bilişsel Teftiş Raporu"),
        automaticallyImplyLeading: isHistory,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Skor Kartı
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
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
            const SizedBox(height: 20),

            // 2. AI Reçetesi Kartı
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
                      else if (prescription != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16, color: Color(0xFF38BDF8)),
                          tooltip: "Reçeteyi Kopyala",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: prescription!));
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
                  else if (prescription != null)
                    Text(
                      prescription,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    )
                  else ...[
                    const Text("Bu karar için henüz bir reçete oluşturulmamış.", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bolt, size: 16),
                      label: const Text("Şimdi AI Reçetesi Üret"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
                      onPressed: () => _generatePrescriptionForHistory(title, blinds, intuits, exempts),
                    ),
                  ],
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
                  _buildFilterChip(0, "Tümü (${allRules.length})"),
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
                      final md = provider.generateMarkdownReport(
                        title: title,
                        score: score,
                        failedIds: blinds.map((r) => r.id).toList(),
                      );
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
                    child: Text(isHistory ? "Geri Dön" : "Tamamla"),
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