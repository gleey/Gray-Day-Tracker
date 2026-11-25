import 'package:flutter/material.dart';

class AppColors {
  static const List<List<Color>> gradients = [
    [Color(0xFF6C63FF), Color(0xFF4834DF)], // Purple
    [Color(0xFFFF6B6B), Color(0xFFEE5A24)], // Red-Orange
    [Color(0xFF1DD1A1), Color(0xFF10AC84)], // Emerald
    [Color(0xFF54A0FF), Color(0xFF2E86DE)], // Blue
    [Color(0xFFFECA57), Color(0xFFFF9F43)], // Yellow-Orange
    [Color(0xFFFF9FF3), Color(0xFFF368E0)], // Pink
    [Color(0xFF00D2D3), Color(0xFF01A3A4)], // Teal
    [Color(0xFFC44569), Color(0xFF9B2335)], // Crimson
  ];

  static List<Color> getGradient(int index) {
    return gradients[index % gradients.length];
  }

  static Color getPrimary(int index) {
    return gradients[index % gradients.length][0];
  }

  static Color getDark(int index) {
    return gradients[index % gradients.length][1];
  }
}
