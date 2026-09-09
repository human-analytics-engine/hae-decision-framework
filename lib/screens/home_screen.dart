// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/decision_provider.dart';
import '../models/category_model.dart';
import '../core/rules_data.dart';
import 'wizard_screen.dart';
import 'decision_detail_sheet.dart';
import 'analytics_screen.dart';

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
            Text("10 Evrensel Kural"),
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

  void _showApiKeyDialog(BuildContext context) {
    final provider = context.read<DecisionProvider>();
    final keyController = TextEditingController(text: provider.geminiApiKey ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Gemini API Anahtarı (Opsiyonel)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Daha derin AI analizleri almak için Google AI Studio anahtarınızı girebilirsiniz. Boş bırakırsanız yerel kural motoru çalışır.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "AIzaSy...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              provider.setApiKey(keyController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text("Kaydet"),
          ),
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
            icon: const Icon(Icons.insights, color: Color(0xFF38BDF8)),
            tooltip: "Bilişsel Analitik",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.key, color: Colors.grey),
            tooltip: "Gemini API Ayarı",
            onPressed: () => _showApiKeyDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            tooltip: "10 Evrensel Kural",
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
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Test edilecek karar nedir?",
                  hintText: "Örn: AWS'ten kendi sunucumuza geçmek",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
              
              // Kategori Çipleri
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: DecisionCategory.values.map((cat) {
                    final isSelected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          children: [
                            Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                            const SizedBox(width: 6),
                            Text(cat.label),
                          ],
                        ),
                        selectedColor: cat.color.withOpacity(0.3),
                        onSelected: (_) => provider.setCategory(cat),
                      ),
                    );
                  }).toList(),
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
              
              const SizedBox(height: 24),
              
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
                                leading: Icon(record.category.icon, color: record.category.color),
                                title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  "${record.category.label} • ${DateFormat('dd MMM, HH:mm').format(record.date)}",
                                  style: const TextStyle(fontSize: 12),
                                ),
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