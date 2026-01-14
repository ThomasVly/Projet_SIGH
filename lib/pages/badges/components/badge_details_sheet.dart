import 'package:flutter/material.dart';
import '../models/badge.dart' as model;

class BadgeDetailsSheet extends StatelessWidget {
  final model.Badge badge;

  const BadgeDetailsSheet({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !badge.isUnlocked;
    final percentage = (badge.progress * 100).clamp(0, 100).toInt();

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle de la bottom sheet
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Grande icône du badge
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: locked ? Colors.grey[300] : badge.color.withValues(alpha: 0.15),
                border: Border.all(
                  color: locked ? Colors.grey[400]! : badge.color,
                  width: 3,
                ),
                boxShadow: locked
                    ? null
                    : [
                        BoxShadow(
                          color: badge.color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      badge.icon,
                      size: 48,
                      color: locked ? Colors.grey[500] : badge.color,
                    ),
                  ),
                  if (locked)
                    const Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Badge de statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: locked
                    ? Colors.grey.shade200
                    : badge.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                locked ? 'Verrouillé' : 'Débloqué',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: locked ? Colors.grey.shade600 : badge.color,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            Text(
              badge.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0056A6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Section "Condition pour obtenir ce badge"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Condition pour obtenir ce badge',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.condition,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section "Votre avancement"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: locked
                    ? Colors.grey[50]
                    : badge.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: locked
                      ? Colors.grey[200]!
                      : badge.color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Votre avancement',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: locked ? Colors.grey[600] : badge.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: badge.progress.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        locked ? Colors.grey[400]! : badge.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    badge.progressLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: locked
                          ? const Color(0xFF4B5563)
                          : badge.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bouton fermer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

