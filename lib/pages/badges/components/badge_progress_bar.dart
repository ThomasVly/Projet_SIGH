import 'package:flutter/material.dart';

class BadgeProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const BadgeProgressBar({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 10,
        backgroundColor: const Color(0xFFE6E9EE),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

