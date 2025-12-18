import 'package:flutter/material.dart';
import '../models/badge.dart' as model;
import 'badge_progress_bar.dart';

/// Contenu de la bottom sheet affichant le détail d'un badge.
///
/// Utilisation :
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => BadgeDetailsSheet(badge: badge),
/// );
/// ```
class BadgeDetailsSheet extends StatelessWidget {
  final model.Badge badge;

  const BadgeDetailsSheet({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !badge.isUnlocked;

    return SafeArea(
      top: false,
      child: Container(
        // Pas de Scaffold ici pour respecter la contrainte.
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),

            // Titre + état (verrouillé / débloqué)
            Row(
              children: [
                Icon(
                  badge.icon,
                  color: locked ? Colors.grey.shade400 : badge.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    badge.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.grey.shade200
                        : badge.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    locked ? 'Verrouillé' : 'Débloqué',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          locked ? Colors.grey.shade600 : badge.color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description courte
            Text(
              badge.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),

            const SizedBox(height: 16),

            // Condition
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

            const SizedBox(height: 18),

            // Avancement (barre + texte)
            const Text(
              'Votre avancement',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            BadgeProgressBar(
              value: badge.progress,
              color: locked ? const Color(0xFFE5E7EB) : badge.color,
            ),
            const SizedBox(height: 6),
            Text(
              badge.progressLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

