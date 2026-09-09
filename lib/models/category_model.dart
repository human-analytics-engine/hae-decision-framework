// lib/models/category_model.dart
import 'package:flutter/material.dart';

enum DecisionCategory {
  investment('Yatırım & Finans', Icons.trending_up, Color(0xFF10B981)),
  architecture('Yazılım & Mimari', Icons.terminal, Color(0xFF38BDF8)),
  career('Kariyer & İş', Icons.work_outline, Color(0xFFF59E0B)),
  personal('Kişisel & Yaşam', Icons.favorite_border, Color(0xFFEC4899));

  final String label;
  final IconData icon;
  final Color color;
  const DecisionCategory(this.label, this.icon, this.color);
}