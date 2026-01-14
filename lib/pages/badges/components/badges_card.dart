import 'package:flutter/material.dart';
import '../models/badge.dart' as model;
import 'badge_card.dart';
import 'badge_details_sheet.dart';

class BadgesCard extends StatelessWidget {
  final List<model.Badge> badges;

  /// Optionnel : si tu veux afficher "1/8" même si tu filtres/tries ailleurs
  final int? totalOverride;

  const BadgesCard({
    super.key,
    required this.badges,
    this.totalOverride,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((b) => b.isUnlocked).length;
    final total = totalOverride ?? badges.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(unlocked: unlocked, total: total),
          const SizedBox(height: 12),
          const _InfoBanner(),
          const SizedBox(height: 14),

          // Grille comme la maquette : 4 colonnes, 2 lignes
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 380;
              final crossAxisCount =
                  isNarrow ? 2 : 4; // 4 colonnes comme la maquette
              final spacing = 14.0;
              final iconSize = isNarrow
                  ? 72.0
                  : 64.0; // sur maquette l’icône est un peu plus compacte

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: badges.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: isNarrow ? 0.95 : 0.85,
                ),
                itemBuilder: (context, index) {
                  final badge = badges[index];

                  return BadgeCard(
                    badge: badge,
                    size: iconSize,
                    onTap: () {
                      // UX : à chaque clic, on affiche le détail du badge
                      // dans une bottom sheet native.
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (sheetContext) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(sheetContext)
                                  .viewInsets
                                  .bottom,
                            ),
                            child: BadgeDetailsSheet(badge: badge),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final int unlocked;
  final int total;

  const _CardHeader({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '🏆  Mes Badges',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$unlocked/$total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 4,
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF2F80ED)),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '💡  Complétez des actions pour débloquer des badges et progresser !',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
