// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/decision_provider.dart';
import '../core/rules_data.dart';
import 'wizard_screen.dart';
import 'decision_detail_sheet.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  HomeScreen({super.key});

  void _showManifesto(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text("10 Evrensel Kural Nedir?"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: RulesData.universalRules.length,
            itemBuilder: (c, i) {
              final r = RulesData.universalRules[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${r.id}. ${r.title}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                    const SizedBox(height: 2),
                    Text(r.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Kapat")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("HAE Decision Framework", style: TextStyle(fontSize: 16, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            tooltip: "Evrensel Kurallar Manifestosu",
            onPressed: () => _showManifesto(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.psychology, size: 56, color: Color(0xFF38BDF8)),
                    const SizedBox(height: 8),
                    const Text(
                      "Cognitive Check-Up",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Kendini kandırmamak için ilk adım.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Hangi kararı test etmek istiyorsun?",
                  hintText: "Örn: X girişimine yatırım yapmak",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      provider.startNewDecision(_controller.text);
                      _controller.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WizardScreen()),
                      );
                    }
                  },
                  child: const Text("Filtreden Geçir", style: TextStyle(fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 28),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Geçmiş Kararlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (provider.history.isNotEmpty)
                    TextButton(
                      onPressed: () => provider.clearHistory(),
                      child: const Text("Temizle", style: TextStyle(color: Colors.redAccent)),
                    )
                ],
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: provider.history.isEmpty
                    ? Center(
                        child: Text(
                          "Henüz bir karar test etmedin.",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.history.length,
                        itemBuilder: (context, index) {
                          final record = provider.history[index];
                          Color scoreColor = record.score >= 80 
                              ? const Color(0xFF10B981) 
                              : (record.score >= 50 ? Colors.orange : Colors.redAccent);
                          
                          return Card(
                            color: Theme.of(context).colorScheme.surface,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => DecisionDetailSheet(record: record),
                                );
                              },
                              child: ListTile(
                                title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(record.date)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: scoreColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: scoreColor),
                                      ),
                                      child: Text(
                                        "%${record.score}",
                                        style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}