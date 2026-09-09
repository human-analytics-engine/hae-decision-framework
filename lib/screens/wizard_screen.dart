// lib/screens/wizard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import 'result_screen.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage(BuildContext context, int totalRules) {
    if (_currentIndex < totalRules - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final rules = provider.rules;

    return Scaffold(
      appBar: AppBar(title: Text("Adım ${_currentIndex + 1} / ${rules.length}")),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Kaydırmayı kapat, sadece butonla geçsin
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: rules.length,
        itemBuilder: (context, index) {
          final rule = rules[index];
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.stage.name.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF38BDF8), letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(rule.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(rule.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(rule.question, style: const TextStyle(fontSize: 18, height: 1.5)),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: () {
                          provider.answerRule(rule.id, false);
                          _nextPage(context, rules.length);
                        },
                        child: const Text("HAYIR (GEÇMEDİM)", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)), // Yeşil
                        onPressed: () {
                          provider.answerRule(rule.id, true);
                          _nextPage(context, rules.length);
                        },
                        child: const Text("EVET (GEÇTİM)", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}