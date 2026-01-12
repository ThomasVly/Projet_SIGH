import 'package:flutter/material.dart';
import '../../../shared/services/level_badge_service.dart';

class BadgeUnlockedDialog extends StatelessWidget {
  final LevelBadge badge;

  const BadgeUnlockedDialog({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: screenHeight * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Animation étoiles
            Stack(
              alignment: Alignment.center,
              children: [
                // Cercle extérieur avec effet brillant
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Badge principal
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      badge.emoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                // Étoiles déco
                ..._buildSparkles(color),
              ],
            ),

            const SizedBox(height: 20),

            // Titre célébration
            const Text(
              '🎉 BADGE DÉBLOQUÉ ! 🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0056A6),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Rareté
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                badge.rarity.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Titre du badge
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
                fontSize: 13,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Niveau
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Niveau ${badge.level}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton continuer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Génial ! 🎉',
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
        ),
      ),
    );
  }

  List<Widget> _buildSparkles(Color color) {
    return [
      Positioned(
        top: 10,
        right: 20,
        child: Text(
          '✨',
          style: TextStyle(
            fontSize: 20,
            color: color,
          ),
        ),
      ),
      Positioned(
        top: 20,
        left: 15,
        child: Text(
          '⭐',
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ),
      Positioned(
        bottom: 15,
        right: 15,
        child: Text(
          '💫',
          style: TextStyle(
            fontSize: 18,
            color: color,
          ),
        ),
      ),
      Positioned(
        bottom: 20,
        left: 20,
        child: Text(
          '✨',
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    ];
  }
}

