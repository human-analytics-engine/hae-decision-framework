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

    return Scaffold(
      appBar: AppBar(
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
            padding: const EdgeInsets.all(24.0),
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
                const SizedBox(height: 8),
                Text(
                  rule.title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text(
                  rule.concept,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),

                // Karara Özel Dinamik Soru Kartı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology, color: Color(0xFF38BDF8), size: 20),
                          SizedBox(width: 8),
                          Text("Bu Karara Özel Sorgu:", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rule.activeQuestion,
                        style: const TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w500),
                      ),
                      if (rule.dynamicTrap != null) ...[
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("⚠️ ", style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                "Tuzak: ${rule.dynamicTrap!}",
                                style: const TextStyle(color: Colors.orange, fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text("Dürüst Değerlendirmen:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 3 Seviyeli Dürüstlük Kartları
                _buildChoiceButton(
                  context: context,
                  rule: rule,
                  level: HonestyLevel.blindSpot,
                  color: const Color(0xFFEF4444),
                  icon: Icons.cancel_outlined,
                  total: rules.length,
                ),
                const SizedBox(height: 12),
                _buildChoiceButton(
                  context: context,
                  rule: rule,
                  level: HonestyLevel.intuitive,
                  color: Colors.orange,
                  icon: Icons.help_outline,
                  total: rules.length,
                ),
                const SizedBox(height: 12),
                _buildChoiceButton(
                  context: context,
                  rule: rule,
                  level: HonestyLevel.concrete,
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_outline,
                  total: rules.length,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.white10, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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