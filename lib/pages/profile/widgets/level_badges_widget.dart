import 'package:flutter/material.dart';
import '../../../shared/services/level_badge_service.dart';
import '../../../pages/badges/components/badge_details_sheet.dart';
import '../../../pages/badges/models/badge.dart' as badge_model;

class LevelBadgesWidget extends StatelessWidget {
  final int currentLevel;

  const LevelBadgesWidget({
    super.key,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    final badgeService = LevelBadgeService();
    final unlockedBadges = badgeService.getUnlockedBadges(currentLevel);
    final nextBadge = badgeService.getNextBadge(currentLevel);
    final lastBadge = badgeService.getLastUnlockedBadge(currentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dernier badge débloqué (si existe)
        if (lastBadge != null) _buildLastBadgeCard(lastBadge),

        // Prochain badge à débloquer
        if (nextBadge != null) ...[
          const SizedBox(height: 12),
          _buildNextBadgeCard(nextBadge),
        ],

        // Statistiques
        const SizedBox(height: 16),
        _buildBadgeStats(badgeService, unlockedBadges.length),

        // Grille de tous les badges
        const SizedBox(height: 16),
        _buildBadgesGrid(unlockedBadges, LevelBadgeService.badges),
      ],
    );
  }

  Widget _buildLastBadgeCard(LevelBadge badge) {
    return Builder(
      builder: (context) {
        final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

        return GestureDetector(
          onTap: () => _showBadgeDetail(context, badge, true),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Row(
        children: [
          // Badge emoji avec effet brillant
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                badge.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '🎉 DÉBLOQUÉ !',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge.rarity,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badge.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0056A6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Niveau ${badge.level}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNextBadgeCard(LevelBadge badge) {
    return Builder(
      builder: (context) {
        final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

        return GestureDetector(
          onTap: () => _showBadgeDetail(context, badge, false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Row(
        children: [
          // Badge verrouillé
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    badge.emoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '🔒 PROCHAIN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge.rarity,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badge.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Débloqué au niveau ${badge.level}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBadgeStats(LevelBadgeService service, int unlockedCount) {
    final total = service.totalBadges;
    final percentage = service.getBadgeCompletionPercentage(currentLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0056A6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progression des badges',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0056A6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$unlockedCount / $total débloqués',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF0056A6),
            child: Text(
              '${percentage.toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(
    List<LevelBadge> unlockedBadges,
    List<LevelBadge> allBadges,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Tous les badges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0056A6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: allBadges.length,
          itemBuilder: (context, index) {
            final badge = allBadges[index];
            final isUnlocked = badge.level <= currentLevel;
            final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

            return GestureDetector(
              onTap: () => _showBadgeDetail(context, badge, isUnlocked),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked ? Colors.white : Colors.grey[300],
                      border: Border.all(
                        color: isUnlocked ? color : Colors.grey[400]!,
                        width: 2,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            badge.emoji,
                            style: TextStyle(
                              fontSize: 28,
                              color: isUnlocked
                                  ? null
                                  : Colors.black.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        if (!isUnlocked)
                          Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Niv. ${badge.level}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? color : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, LevelBadge badge, bool isUnlocked) {
    // Convertir LevelBadge en Badge pour BadgeDetailsSheet
    final badgeModel = badge_model.Badge(
      id: 'level_${badge.level}',
      title: badge.title,
      description: badge.description,
      icon: _getIconFromRarity(badge.rarity),
      color: Color(LevelBadgeService.getColorByRarity(badge.rarity)),
      condition: 'Atteindre le niveau ${badge.level}',
      status: isUnlocked ? badge_model.BadgeStatus.unlocked : badge_model.BadgeStatus.locked,
      progress: isUnlocked ? 1.0 : (currentLevel / badge.level).clamp(0.0, 1.0),
      progressLabel: isUnlocked
          ? 'Badge débloqué !'
          : 'Niveau actuel: $currentLevel / ${badge.level}',
    );

    // Afficher la bottom sheet avec les détails du badge
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BadgeDetailsSheet(badge: badgeModel),
    );
  }

  IconData _getIconFromRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'commun':
        return Icons.eco;
      case 'rare':
        return Icons.flash_on;
      case 'épique':
        return Icons.stars;
      case 'légendaire':
        return Icons.emoji_events;
      case 'mythique':
        return Icons.diamond;
      case 'divin':
        return Icons.auto_awesome;
      default:
        return Icons.military_tech;
    }
  }
}

