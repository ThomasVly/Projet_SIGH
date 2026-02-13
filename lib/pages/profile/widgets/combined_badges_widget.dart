import 'package:flutter/material.dart';
import '../../../shared/services/level_badge_service.dart';
import '../../badges/services/badge_service.dart';
import '../../badges/models/badge.dart' as badge_model;
import '../../badges/components/badge_details_sheet.dart';

/// Widget qui combine les badges de niveau et les badges d'énergie
/// sous une seule section "Mes Badges"
class CombinedBadgesWidget extends StatelessWidget {
  final int currentLevel;
  final int quizCount;
  final int challengeCount;
  final int articleCount;
  final int loginStreak;
  final double energySaved;

  const CombinedBadgesWidget({
    super.key,
    required this.currentLevel,
    this.quizCount = 0,
    this.challengeCount = 0,
    this.articleCount = 0,
    this.loginStreak = 0,
    this.energySaved = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final levelBadgeService = LevelBadgeService();

    // Obtenir les badges d'énergie (le compteur est maintenant calculé dans le service)
    final energyBadges = const BadgeService().fetchBadges(
      quizCount: quizCount,
      challengeCount: challengeCount,
      articleCount: articleCount,
      loginStreak: loginStreak,
      energySaved: energySaved,
      unlockedBadgesCount: 0, // Non utilisé maintenant
    );

    final unlockedLevelBadges = levelBadgeService.getUnlockedBadges(currentLevel);
    final lastBadge = levelBadgeService.getLastUnlockedBadge(currentLevel);
    final nextBadge = levelBadgeService.getNextBadge(currentLevel);

    final totalLevelBadges = LevelBadgeService.badges.length;
    final totalEnergyBadges = energyBadges.length;
    final unlockedEnergyBadges = energyBadges.where((b) => b.isUnlocked).length;
    final totalBadges = totalLevelBadges + totalEnergyBadges;
    final totalUnlocked = unlockedLevelBadges.length + unlockedEnergyBadges;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre unifié "Mes Badges"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Mes Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0056A6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Débloquez des badges en progressant et en réalisant des actions',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dernier badge débloqué (si existe)
          if (lastBadge != null) ...[
            _buildLastBadgeCard(context, lastBadge),
            const SizedBox(height: 12),
          ],

          // Prochain badge à débloquer
          if (nextBadge != null) ...[
            _buildNextBadgeCard(context, nextBadge),
            const SizedBox(height: 16),
          ],

          // Statistiques globales
          _buildBadgeStats(totalUnlocked, totalBadges),

          const SizedBox(height: 16),

          // Grille unifiée de tous les badges
          _buildUnifiedBadgesGrid(context, levelBadgeService, energyBadges),
        ],
      ),
    );
  }

  Widget _buildLastBadgeCard(BuildContext context, LevelBadge badge) {
    final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

    return GestureDetector(
      onTap: () => _showLevelBadgeDetail(context, badge, true),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextBadgeCard(BuildContext context, LevelBadge badge) {
    final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

    return GestureDetector(
      onTap: () => _showLevelBadgeDetail(context, badge, false),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.grey[400]!, width: 2),
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
                  const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
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
  }

  Widget _buildBadgeStats(int unlocked, int total) {
    final percentage = total > 0 ? (unlocked / total * 100) : 0;

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
                '$unlocked / $total débloqués',
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

  Widget _buildUnifiedBadgesGrid(
    BuildContext context,
    LevelBadgeService levelBadgeService,
    List<badge_model.Badge> energyBadges,
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

        // Grille unifiée avec tous les badges
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: LevelBadgeService.badges.length + energyBadges.length,
          itemBuilder: (context, index) {
            // D'abord les badges de niveau, puis les badges d'énergie
            if (index < LevelBadgeService.badges.length) {
              // Badge de niveau
              final badge = LevelBadgeService.badges[index];
              final isUnlocked = badge.level <= currentLevel;
              final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

              return GestureDetector(
                onTap: () => _showLevelBadgeDetail(context, badge, isUnlocked),
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
                            const Center(
                              child: Icon(
                                Icons.lock,
                                color: Colors.grey,
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
                        color: isUnlocked ? const Color(0xFF0056A6) : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            } else {
              // Badge d'énergie
              final energyIndex = index - LevelBadgeService.badges.length;
              final badge = energyBadges[energyIndex];
              final isUnlocked = badge.isUnlocked;

              return GestureDetector(
                onTap: () => _showEnergyBadgeDetail(context, badge),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked ? Colors.white : Colors.grey[300],
                        border: Border.all(
                          color: isUnlocked ? badge.color : Colors.grey[400]!,
                          width: 2,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: badge.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              badge.icon,
                              size: 28,
                              color: isUnlocked
                                  ? badge.color
                                  : Colors.grey[500],
                            ),
                          ),
                          if (!isUnlocked)
                            const Center(
                              child: Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? const Color(0xFF0056A6) : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _showLevelBadgeDetail(BuildContext context, LevelBadge badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final color = Color(LevelBadgeService.getColorByRarity(badge.rarity));

        // Calculer la progression vers ce badge
        final progressPercent = isUnlocked
            ? 100.0
            : (currentLevel / badge.level * 100).clamp(0, 99);

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
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

                // Icône du badge
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked ? Colors.white : Colors.grey[300],
                    border: Border.all(
                      color: isUnlocked ? color : Colors.grey[400]!,
                      width: 3,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
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
                            fontSize: 48,
                            color: isUnlocked
                                ? null
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      if (!isUnlocked)
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

                // Badge rareté + statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge.rarity,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isUnlocked ? 'Débloqué' : 'Verrouillé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked ? const Color(0xFF4CAF50) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
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
                        'Atteindre le niveau ${badge.level}',
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
                    color: isUnlocked
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.05)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnlocked
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                          : Colors.grey[200]!,
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
                            '${progressPercent.toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? const Color(0xFF4CAF50) : color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressPercent / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? const Color(0xFF4CAF50) : color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        isUnlocked
                            ? '✅ Badge débloqué !'
                            : 'Niveau actuel : $currentLevel / ${badge.level}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? const Color(0xFF4CAF50) : const Color(0xFF4B5563),
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
      },
    );
  }

  void _showEnergyBadgeDetail(BuildContext context, badge_model.Badge badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: BadgeDetailsSheet(badge: badge),
        );
      },
    );
  }
}

