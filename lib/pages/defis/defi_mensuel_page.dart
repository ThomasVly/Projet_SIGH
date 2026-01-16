import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projet_sigh_grp1/common-widget/header/header_widget.dart';
import 'package:projet_sigh_grp1/shared/local_database/db-creator.dart';
import 'package:projet_sigh_grp1/shared/firebase/firestore_service.dart';
import 'models/challenge_models.dart';

class DefiMensuelPage extends StatefulWidget {
  const DefiMensuelPage({super.key});

  @override
  State<DefiMensuelPage> createState() => _DefiMensuelPageState();
}

class _DefiMensuelPageState extends State<DefiMensuelPage> {
  late Future<List<ChallengeWithStatus>> _futureChallenges;

  @override
  void initState() {
    super.initState();
    _futureChallenges = _loadChallenges();
  }

  /// 1) Récupérer les définitions depuis Firestore
  Future<List<ChallengeDefinition>> _loadDefinitionsFromFirebase() async {
    final rawList = await FirestoreService.getChallenges();

    return rawList
        .map(
          (data) => ChallengeDefinition.fromFirestore(
            data,
            data['id'] as String,
          ),
        )
        .toList();
  }

  /// 2) Récupérer les statuts (complet / non) depuis SQLite
  Future<List<ChallengeStatus>> _loadStatusesFromLocal() async {
    final Database db = await DatabaseHelper.instance.database;
    final rows = await db.query('Challenges');
    return rows.map((row) => ChallengeStatus.fromDb(row)).toList();
  }

  /// 3) Upsert d'un statut en local
  Future<void> _upsertStatusToLocal({
    required String id,
    required bool completed,
    required int reward,
  }) async {
    final Database db = await DatabaseHelper.instance.database;

    await db.insert(
      'Challenges',
      {
        'id': id,
        'completed': completed ? 1 : 0,
        'reward': reward,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 4) Fusion Firebase + SQLite
  Future<List<ChallengeWithStatus>> _loadChallenges() async {
    final definitions = await _loadDefinitionsFromFirebase();
    final statuses = await _loadStatusesFromLocal();

    final statusById = {
      for (final s in statuses) s.id: s,
    };

    final List<ChallengeWithStatus> result = definitions.map((def) {
      final status = statusById[def.id] ??
          ChallengeStatus(
            id: def.id,
            completed: false,
            reward: def.reward,
          );
      return ChallengeWithStatus(definition: def, status: status);
    }).toList();

    // On s'assure que le défi courant (mois actuel) est en premier
    result.sort((a, b) {
      if (a.definition.isCurrent && !b.definition.isCurrent) return -1;
      if (!a.definition.isCurrent && b.definition.isCurrent) return 1;
      return 0;
    });

    return result;
  }

  Future<void> _toggleCompleted(ChallengeWithStatus challenge) async {
    final newCompleted = !challenge.status.completed;

    await _upsertStatusToLocal(
      id: challenge.definition.id,
      completed: newCompleted,
      reward: challenge.definition.reward,
    );

    setState(() {
      _futureChallenges = _loadChallenges();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _futureChallenges = _loadChallenges();
    });
  }

    void _showChallengeDetails(ChallengeWithStatus challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: _CurrentChallengeCard(
            challenge: challenge,
            onToggleCompleted: () {
              Navigator.of(ctx).pop();      // fermer la fiche
              _toggleCompleted(challenge);  // mettre à jour la progression
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            
            Stack(
              children: [
                // Header : on garde juste le fond, sans titre
                const HeaderWidget(
                  title: '',
                  isHomePage: false,
                ),

                // Flèche + titre alignés comme dans un AppBar
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0, // permet de centrer verticalement dans le header
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Défi mensuel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // même taille que le header
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
                        Expanded(
              child: FutureBuilder<List<ChallengeWithStatus>>(
                future: _futureChallenges,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erreur lors du chargement des défis : ${snapshot.error}',
                      ),
                    );
                  }



                  final challenges = snapshot.data ?? [];

                  if (challenges.isEmpty) {
                    return const Center(
                      child: Text('Aucun défi disponible pour le moment.'),
                    );
                  }

                  // On cherche le défi du mois courant
                  final current = challenges.firstWhere(
                    (c) => c.definition.isCurrent,
                    orElse: () => challenges.first,
                  );

                  // On ne garde en "précédents" que les défis dans le passé
                  final previous = challenges
                      .where((c) =>
                          c.definition.id != current.definition.id &&
                          c.definition.isPast)
                      .toList()
                    ..sort(
                      (a, b) => b.definition.month.compareTo(a.definition.month),
                    );

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CurrentChallengeCard(
                            challenge: current,
                            onToggleCompleted: () => _toggleCompleted(current),
                          ),
                          const SizedBox(height: 28),
                          _PreviousChallengesSection(
                            challenges: previous,
                            onCardTap: _showChallengeDetails,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======= CARTE DÉFI ACTUEL (haut) =======
/// ======= CARTE DÉFI ACTUEL (haut) =======
class _CurrentChallengeCard extends StatelessWidget {
  final ChallengeWithStatus challenge;
  final VoidCallback onToggleCompleted;

  const _CurrentChallengeCard({
    required this.challenge,
    required this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final def = challenge.definition;
    final status = challenge.status;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        // 🔵 Fond bleu façon maquette
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0062D9),
            Color(0xFF0047B5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0047B5).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne "Défi en cours" / mois
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Chip(
                label: 'Défi en cours',
                background: Color(0x331FFFFFF),
                textColor: Colors.white,
              ),
              _Chip(
                label: def.monthLabel,
                background: Colors.white,
                textColor: const Color(0xFF0062D9),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // (Pas d’icône centrale)

          // Titre
          Text(
            def.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            def.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),

          // Bloc "objectif" avec couleurs maquette
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0x331FFFFFF), // bleu plus foncé
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.track_changes,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    def.reminder,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Bouton unique centré avec les couleurs de la maquette
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: status.completed ? 240 : 220,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0062D9),
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: onToggleCompleted,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Icon(
                        status.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        key: ValueKey(status.completed),
                        size: 20,
                        color: const Color(0xFF0062D9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        status.completed
                            ? 'Défi complété'
                            : 'Marquer comme fait',
                        key: ValueKey(status.completed),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: const Color(0xFF0062D9),
                              fontWeight: status.completed
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _Chip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: textColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}

/// ======= SECTION DÉFIS PRÉCÉDENTS =======
class _PreviousChallengesSection extends StatelessWidget {
  final List<ChallengeWithStatus> challenges;
  final void Function(ChallengeWithStatus) onCardTap;

  const _PreviousChallengesSection({
    required this.challenges,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return Text(
        'Pas encore de défis précédents.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Défis précédents',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 500;
            final crossAxisCount = isSmall ? 1 : 2;
            final totalSpacing = isSmall ? 0.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - totalSpacing) / crossAxisCount;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: challenges
                  .map(
                    (c) => SizedBox(
                      width: itemWidth,
                      child: _PreviousChallengeCard(
                        title: c.definition.title,
                        monthLabel: c.definition.monthLabel,
                        completed: c.status.completed,
                        onTap: () => onCardTap(c),   // 👈 clic
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
class _PreviousChallengeCard extends StatelessWidget {
  final String title;
  final String monthLabel;
  final bool completed;
  final VoidCallback? onTap;

  const _PreviousChallengeCard({
    required this.title,
    required this.monthLabel,
    required this.completed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const red = Color(0xFFEF4444);

    final Color statusColor = completed ? green : red;
    final String statusLabel = completed ? 'Réussi' : 'Non atteint';
    final Color borderColor = completed ? green : red;

    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mois
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
          const SizedBox(height: 6),

          // Titre du défi
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
          ),
          const SizedBox(height: 12),

          // BADGE À DROITE 👉
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: card,
            ),
          );
  }
}

