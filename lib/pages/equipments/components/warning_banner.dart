import 'package:flutter/material.dart';

class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFC0001)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La consommation totale et le coût estimé sont indiqués à titre indicatifs uniquement !'
              ' Ces valeurs peuvent différer de la réalité. En orange, ce sont les appareils qui consomment le plus.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFC0001),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}