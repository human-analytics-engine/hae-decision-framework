// lib/screens/decision_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/decision_history_model.dart';
import '../core/rules_data.dart';
import '../providers/decision_provider.dart';

class DecisionDetailSheet extends StatelessWidget {
  final DecisionHistory record;

  const DecisionDetailSheet({super.key, required this.record});

  void _showSavedPrescription(BuildContext context) {
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
                  Text("Kayıtlı AI Reçetesi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              Text(record.prescription ?? "Bu karar için bir AI reçetesi oluşturulmamış.", style: const TextStyle(fontSize: 15, height: 1.6)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Kapat"),
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
    Color scoreColor = record.score >= 80 
        ? const Color(0xFF10B981) 
        : (record.score >= 50 ? Colors.orange : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${record.category.label} • ${DateFormat('dd MMMM yyyy, HH:mm').format(record.date)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor),
                ),
                child: Text("%${record.score}", style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          const Divider(height: 28),
          const Text("Kural Dökümü & Teftiş Durumu", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: RulesData.universalRules.length,
              itemBuilder: (context, index) {
                final rule = RulesData.universalRules[index];
                final isFailed = record.failedRuleIds.contains(rule.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isFailed ? Colors.redAccent.withOpacity(0.3) : Colors.transparent),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isFailed ? Icons.cancel_outlined : Icons.check_circle_outline,
                      color: isFailed ? Colors.redAccent : const Color(0xFF10B981),
                      size: 22,
                    ),
                    title: Text(rule.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(rule.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          if (record.prescription != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 18),
                label: const Text("Kayıtlı AI Reçetesini Oku", style: TextStyle(color: Color(0xFF38BDF8))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                ),
                onPressed: () => _showSavedPrescription(context),
              ),
            ),
            const SizedBox(height: 8),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Tüm Raporu Kopyala"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                final md = context.read<DecisionProvider>().generateMarkdownReport(
                  title: record.title,
                  score: record.score,
                  failedIds: record.failedRuleIds,
                  category: record.category,
                );
                Clipboard.setData(ClipboardData(text: md));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tüm rapor panoya kopyalandı!")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}