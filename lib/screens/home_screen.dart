// lib/screens/home_screen.dart
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/decision_provider.dart';
import '../models/ai_provider.dart';
import 'wizard_screen.dart';
import 'result_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;

  final List<String> _quickTemplates = [
    "İşten ayrılıp kendi ajansımı kurmak",
    "Yazılımda Monolith'ten Microservice'e geçmek",
    "Portföyün %40'ı ile yeni bir yatırıma girmek",
    "Ortakla yeni bir SaaS ürünü inşa etmek",
  ];

  void _startVoiceInput() {
    setState(() => _isListening = true);
    try {
      js.context.callMethod('startSpeechRecognition', [
        (String text) {
          setState(() {
            _controller.text = text;
            _isListening = false;
          });
        }
      ]);
    } catch (_) {
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ses tanıma bu tarayıcıda başlatılamadı.")),
        );
      }
    }
  }

  void _startDecision(BuildContext context) async {
    if (_controller.text.trim().isEmpty) return;
    
    final provider = context.read<DecisionProvider>();
    final title = _controller.text.trim();
    _controller.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Card(
          color: const Color(0xFF1E293B),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF38BDF8)),
                const SizedBox(height: 16),
                Text("${provider.selectedProvider.label} Sorgu Seti Hazırlıyor...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                const Text("Karar analiz ediliyor ve özel tuzaklar üretiliyor.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );

    await provider.startNewDecision(title);

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WizardScreen()));
    }
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: const Text("Tüm Geçmiş Silinsin mi?"),
        content: const Text("Kayıtlı tüm kararlarınız ve AI reçeteleriniz cihazınızdan kalıcı olarak temizlenecektir."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<DecisionProvider>().clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text("Hepsini Sil"),
          ),
        ],
      ),
    );
  }

  void _showApiSettingsDialog(BuildContext context) {
    final provider = context.read<DecisionProvider>();
    AiProvider chosenProvider = provider.selectedProvider;
    final keyController = TextEditingController(text: provider.apiKey ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final hasKey = provider.apiKey != null && provider.apiKey!.isNotEmpty;

          return AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Frontier AI Ayarı", style: TextStyle(fontSize: 18)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (hasKey ? const Color(0xFF10B981) : Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: hasKey ? const Color(0xFF10B981) : Colors.grey),
                  ),
                  child: Text(
                    hasKey ? "● Aktif" : "○ Girilmedi",
                    style: TextStyle(color: hasKey ? const Color(0xFF10B981) : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI Sağlayıcısını Seçin:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AiProvider>(
                    value: chosenProvider,
                    isExpanded: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: AiProvider.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => chosenProvider = val);
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(chosenProvider.description, style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: keyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "${chosenProvider.label} API Key",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Anahtarınız sadece tarayıcınızda saklanır, üçüncü şahıslara iletilmez.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            actions: [
              if (hasKey)
                TextButton(
                  onPressed: () {
                    provider.setProviderAndKey(chosenProvider, '');
                    Navigator.pop(ctx);
                  },
                  child: const Text("Sil", style: TextStyle(color: Colors.redAccent)),
                ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Kapat")),
              ElevatedButton(
                onPressed: () {
                  provider.setProviderAndKey(chosenProvider, keyController.text.trim());
                  Navigator.pop(ctx);
                },
                child: const Text("Kaydet"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 400; // Galaxy Z Fold / Küçük ekran kontrolü

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isNarrow ? "HAE Karar Lab" : "HAE Sokratik Karar Lab", style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
              ),
              child: const Text(DecisionProvider.appVersion, style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights, color: Color(0xFF38BDF8)),
            tooltip: "Bilişsel Analitik",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          IconButton(
            icon: Icon(
              Icons.key,
              color: (provider.apiKey != null && provider.apiKey!.isNotEmpty) ? const Color(0xFF10B981) : Colors.grey,
            ),
            tooltip: "Frontier AI Ayarı",
            onPressed: () => _showApiSettingsDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Hangi kararı test etmek istiyorsun?",
                  hintText: "Örn: Ahmet ile ortak SaaS başlatmak",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.redAccent : const Color(0xFF38BDF8),
                    ),
                    tooltip: "Sesle Dikte Et (Türkçe)",
                    onPressed: _startVoiceInput,
                  ),
                ),
                onSubmitted: (_) => _startDecision(context),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _quickTemplates.map((template) {
                  return ActionChip(
                    label: Text(template, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    onPressed: () => _controller.text = template,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startDecision(context),
                  child: const Text("Sokratik Filtreden Geçir", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Geçmiş Kararlar", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  if (provider.history.isNotEmpty)
                    TextButton(
                      onPressed: () => _confirmClearHistory(context),
                      child: const Text("Temizle", style: TextStyle(color: Colors.redAccent)),
                    )
                ],
              ),
              const SizedBox(height: 6),

              Expanded(
                child: provider.history.isEmpty
                    ? Center(
                        child: Text("Henüz bir karar test etmedin.", style: TextStyle(color: Colors.grey[600])),
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
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ResultScreen(historyRecord: record)),
                                );
                              },
                              child: ListTile(
                                leading: const Icon(Icons.psychology_outlined, color: Color(0xFF38BDF8)),
                                title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(record.date),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: scoreColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: scoreColor),
                                      ),
                                      child: Text(
                                        "%${record.score}",
                                        style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
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