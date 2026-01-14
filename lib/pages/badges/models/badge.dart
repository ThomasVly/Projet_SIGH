import 'package:flutter/material.dart';

enum BadgeStatus { locked, unlocked }

class Badge {
  final String id;
  final String title;
  final String description;
  /// Condition textuelle pour obtenir le badge (ex: "Atteindre 50 kWh économisés").
  final String condition;
  final String progressLabel;
  final double progress; // 0 → 1
  final BadgeStatus status;
  final IconData icon;
  final Color color;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    required this.progressLabel,
    required this.progress,
    required this.status,
    required this.icon,
    required this.color,
  });

  bool get isUnlocked => status == BadgeStatus.unlocked;
}

