import 'package:flutter/material.dart';
import '../models/badge.dart' as model;
import 'badge_progress_bar.dart';

/// Carte de badge réutilisable.
///
/// - Affiche l'icône, le titre, la barre de progression et le libellé.
/// - `onTap` est optionnel pour permettre l'ouverture d'un détail ou autre action.
class BadgeCard extends StatelessWidget {
  final model.Badge badge;
  final double size;
  final VoidCallback? onTap;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !badge.isUnlocked;
    final iconBg = badge.color.withOpacity(locked ? 0.08 : 0.18);
    final iconColor = locked ? const Color(0xFFCAD0DA) : badge.color;
    final textColor =
        locked ? const Color(0xFFB0B6C0) : const Color(0xFF111827);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            badge.icon,
            color: iconColor,
            size: size * 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        BadgeProgressBar(
          value: badge.progress,
          color: locked ? const Color(0xFFE6E9EE) : badge.color,
        ),
        const SizedBox(height: 4),
        Text(
          badge.progressLabel,
          style: TextStyle(
            fontSize: 12,
            color: locked ? const Color(0xFFB0B6C0) : const Color(0xFF4A5568),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    // Si aucun onTap passé, on garde un simple contenu (meilleures perfs / pas d'effet ripple inutile).
    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: content,
      ),
    );
  }
}
