// lib/screens/wizard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import '../models/rule_model.dart';
import 'result_screen.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _handleBackNavigation(BuildContext context) {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      _showExitConfirmation(context);
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: const Text("Testten Çıkılsın mı?"),
        content: const Text("Şu anki ilerlemeniz ve cevaplarınız silinecektir."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Devam Et")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Çık"),
          ),
        ],
      ),
    );
  }

  void _selectLevel(BuildContext context, RuleModel rule, HonestyLevel level, int total) {
    context.read<DecisionProvider>().answerRule(rule.id, level);

    if (_currentIndex < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final rules = provider.rules;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackNavigation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackNavigation(context),
          ),
          title: Text("Adım ${_currentIndex + 1} / ${rules.length}"),
          centerTitle: true,
        ),
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemCount: rules.length,
          itemBuilder: (context, index) {
            final rule = rules[index];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.stage.name.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rule.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rule.concept,
                    style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 18),

                  // Dinamik Soru Kartı
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, color: Color(0xFF38BDF8), size: 18),
                            SizedBox(width: 8),
                            Text("Bu Karara Özel Sorgu:", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          rule.activeQuestion,
                          style: const TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w500),
                        ),
                        if (rule.dynamicTrap != null) ...[
                          const Divider(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("⚠️ ", style: TextStyle(fontSize: 13)),
                              Expanded(
                                child: Text(
                                  "Tuzak: ${rule.dynamicTrap!}",
                                  style: const TextStyle(color: Colors.orange, fontSize: 12, height: 1.35),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Dürüst Değerlendirmen:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 4 Seviyeli Kartlar
                  _buildChoiceButton(
                    context: context,
                    rule: rule,
                    level: HonestyLevel.blindSpot,
                    color: const Color(0xFFEF4444),
                    icon: Icons.cancel_outlined,
                    total: rules.length,
                  ),
                  const SizedBox(height: 8),
                  _buildChoiceButton(
                    context: context,
                    rule: rule,
                    level: HonestyLevel.intuitive,
                    color: Colors.orange,
                    icon: Icons.help_outline,
                    total: rules.length,
                  ),
                  const SizedBox(height: 8),
                  _buildChoiceButton(
                    context: context,
                    rule: rule,
                    level: HonestyLevel.concrete,
                    color: const Color(0xFF10B981),
                    icon: Icons.check_circle_outline,
                    total: rules.length,
                  ),
                  const SizedBox(height: 8),
                  _buildChoiceButton(
                    context: context,
                    rule: rule,
                    level: HonestyLevel.exempt,
                    color: Colors.blueGrey,
                    icon: Icons.remove_circle_outline,
                    total: rules.length,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required BuildContext context,
    required RuleModel rule,
    required HonestyLevel level,
    required Color color,
    required IconData icon,
    required int total,
  }) {
    final isSelected = rule.selectedLevel == level;

    return InkWell(
      onTap: () => _selectLevel(context, rule, level, total),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.white10, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}