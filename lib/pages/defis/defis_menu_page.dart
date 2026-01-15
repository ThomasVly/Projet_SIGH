// lib/pages/defis/defis_menu_page.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:projet_sigh_grp1/shared/local_database/db-creator.dart';
import 'package:projet_sigh_grp1/shared/firebase/firestore_service.dart';
import 'defi_mensuel_page.dart';

class DefisMenuPage extends StatefulWidget {
  const DefisMenuPage({super.key});

  @override
  State<DefisMenuPage> createState() => _DefisMenuPageState();
}

class _DefisMenuPageState extends State<DefisMenuPage> {
  bool _hasActiveChallenge = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentChallengeStatus();
  }

  Future<void> _loadCurrentChallengeStatus() async {
    try {
      final Database db = await DatabaseHelper.instance.database;
      final defs = await FirestoreService.getChallenges();

      if (defs.isEmpty) {
        setState(() => _hasActiveChallenge = false);
        return;
      }

      Map<String, dynamic>? current;
      for (final c in defs) {
        if (c['isCurrent'] == true) {
          current = c;
          break;
        }
      }

      if (current == null) {
        setState(() => _hasActiveChallenge = false);
        return;
      }

      final String currentId = current['id'];
      final rows = await db.query(
        'Challenges',
        where: 'id = ?',
        whereArgs: [currentId],
      );

      bool completed = false;
      if (rows.isNotEmpty) {
        final row = rows.first;
        completed = row['completed'] == 1;
      }

      setState(() => _hasActiveChallenge = !completed);
    } catch (e) {
      debugPrint('Erreur: $e');
      setState(() => _hasActiveChallenge = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DefisMenuContent(
      hasActiveChallenge: _hasActiveChallenge,
    );
  }
}

class _DefisMenuContent extends StatelessWidget {
  final bool hasActiveChallenge;

  const _DefisMenuContent({
    required this.hasActiveChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Testez vos connaissances',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quiz et défis pour apprendre à économiser l’énergie !',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
          const SizedBox(height: 24),

          // ---- Carte QUIZ ----
          _MenuCard(
            icon: Icons.flag_circle_outlined,
            iconBackground: const Color(0xFFE0F2FE),
            title: 'Quiz',
            onTap: () {
              // TODO: Navigation vers Quiz
            },
          ),

          const SizedBox(height: 16),

          // ---- Carte DEFIS ----
          _MenuCard(
            icon: Icons.emoji_events_outlined,
            iconBackground: const Color(0xFFFEE2E2),
            title: 'Défis',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DefiMensuelPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Text(
            'Vos statistiques',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 16),

          Row(
            children: const [
              Expanded(
                child: _StatCard(
                  label: 'Quiz complétés',
                  value: '0',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Défis relevés',
                  value: '0',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Taux de réussite',
                  value: '0%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


/// =======================
///     Menu Card simple
/// =======================
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final VoidCallback onTap;
  final Color? borderColor;

  const _MenuCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: const Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}


/// =======================
///     Stat Card
/// =======================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D4ED8),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
        ],
      ),
    );
  }
}
