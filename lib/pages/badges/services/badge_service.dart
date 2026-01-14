import 'package:flutter/material.dart';
import '../models/badge.dart' as model;

class BadgeService {
  const BadgeService();

  /// Retourne la liste des badges avec progression calculée dynamiquement
  /// en fonction des statistiques de l'utilisateur
  List<model.Badge> fetchBadges({
    int quizCount = 0,
    int challengeCount = 0,
    int articleCount = 0,
    int loginStreak = 0,
    double energySaved = 0.0,
    int unlockedBadgesCount = 0,
  }) {
    // Badge Expert Quiz
    final expertQuizProgress = (quizCount / 5).clamp(0.0, 1.0);
    final expertQuizUnlocked = quizCount >= 5;

    // Badge Champion
    final championProgress = (challengeCount / 3).clamp(0.0, 1.0);
    final championUnlocked = challengeCount >= 3;

    // Badge Lecteur
    final lecteurProgress = (articleCount / 10).clamp(0.0, 1.0);
    final lecteurUnlocked = articleCount >= 10;

    // Badge Assidu
    final assiduProgress = (loginStreak / 7).clamp(0.0, 1.0);
    final assiduUnlocked = loginStreak >= 7;

    // Badge Économe
    final economeProgress = (energySaved / 50).clamp(0.0, 1.0);
    final economeUnlocked = energySaved >= 50;

    // Badge Éco-expert
    final ecoExpertProgress = (energySaved / 200).clamp(0.0, 1.0);
    final ecoExpertUnlocked = energySaved >= 200;

    // Badge Perfectionniste (tous les autres badges débloqués)
    final totalBadgesToUnlock = 7; // Tous sauf Perfectionniste
    final perfectionnisteProgress = (unlockedBadgesCount / totalBadgesToUnlock).clamp(0.0, 1.0);
    final perfectionnisteUnlocked = unlockedBadgesCount >= totalBadgesToUnlock;

    return [
      const model.Badge(
        id: 'premiers_pas',
        title: 'Premiers pas',
        description: 'Votre tout premier badge sur SIGH.',
        condition: 'Compléter une première action dans l\'application.',
        progressLabel: '1/1',
        progress: 1,
        status: model.BadgeStatus.unlocked,
        icon: Icons.directions_walk,
        color: Color(0xFF6E3CE3),
      ),
      model.Badge(
        id: 'econome',
        title: 'Économe',
        description: 'Réduisez votre consommation d\'énergie.',
        condition: 'Atteindre 50 kWh d\'économie.',
        progressLabel: '${energySaved.toStringAsFixed(1)}/50 kWh',
        progress: economeProgress,
        status: economeUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF82C341),
      ),
      model.Badge(
        id: 'expert_quiz',
        title: 'Expert Quiz',
        description: 'Testez vos connaissances avec les quiz énergie.',
        condition: 'Terminer 5 quiz.',
        progressLabel: '$quizCount/5 quiz',
        progress: expertQuizProgress,
        status: expertQuizUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.track_changes,
        color: const Color(0xFF4AA3FF),
      ),
      model.Badge(
        id: 'champion',
        title: 'Champion',
        description: 'Relèvez les défis proposés chaque semaine.',
        condition: 'Réussir 3 défis.',
        progressLabel: '$challengeCount/3 défis',
        progress: championProgress,
        status: championUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFF5A524),
      ),
      model.Badge(
        id: 'lecteur',
        title: 'Lecteur',
        description: 'Informez-vous avec nos articles.',
        condition: 'Lire 10 articles.',
        progressLabel: '$articleCount/10 articles',
        progress: lecteurProgress,
        status: lecteurUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.menu_book_outlined,
        color: const Color(0xFF4AA3FF),
      ),
      model.Badge(
        id: 'assidu',
        title: 'Assidu',
        description: 'Revenez régulièrement dans l\'application.',
        condition: 'Se connecter 7 jours d\'affilée.',
        progressLabel: '$loginStreak/7 jours',
        progress: assiduProgress,
        status: assiduUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.local_fire_department_outlined,
        color: const Color(0xFFF65D5D),
      ),
      model.Badge(
        id: 'eco_expert',
        title: 'Éco-expert',
        description: 'Devenez un expert des économies d\'énergie.',
        condition: 'Cumuler 200 kWh d\'économie.',
        progressLabel: '${energySaved.toStringAsFixed(1)}/200 kWh',
        progress: ecoExpertProgress,
        status: ecoExpertUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.eco_outlined,
        color: const Color(0xFF82C341),
      ),
      model.Badge(
        id: 'perfectionniste',
        title: 'Perfectionniste',
        description: 'Vous avez débloqué tous les autres badges.',
        condition: 'Débloquer l\'ensemble des badges.',
        progressLabel: '$unlockedBadgesCount/$totalBadgesToUnlock badges',
        progress: perfectionnisteProgress,
        status: perfectionnisteUnlocked ? model.BadgeStatus.unlocked : model.BadgeStatus.locked,
        icon: Icons.star_outline,
        color: const Color(0xFFB0B6C0),
      ),
    ];
  }
}
