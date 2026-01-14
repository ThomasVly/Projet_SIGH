/// Système de badges de niveau
class LevelBadge {
  final int level;
  final String emoji;
  final String title;
  final String description;
  final String rarity;

  const LevelBadge({
    required this.level,
    required this.emoji,
    required this.title,
    required this.description,
    required this.rarity,
  });
}

/// Service pour gérer les badges de niveau
class LevelBadgeService {
  static final LevelBadgeService _instance = LevelBadgeService._internal();
  factory LevelBadgeService() => _instance;
  LevelBadgeService._internal();

  /// Liste complète des badges de niveau
  static const List<LevelBadge> badges = [
    // Débutant (1-5)
    LevelBadge(
      level: 1,
      emoji: '🌱',
      title: 'Première Étincelle',
      description: 'Bienvenue dans l\'aventure énergétique !',
      rarity: 'Commun',
    ),
    LevelBadge(
      level: 2,
      emoji: '⚡',
      title: 'Éclair Novice',
      description: 'Tu commences à générer de l\'énergie !',
      rarity: 'Commun',
    ),
    LevelBadge(
      level: 3,
      emoji: '💡',
      title: 'Lumière Naissante',
      description: 'Tes connaissances illuminent le chemin',
      rarity: 'Commun',
    ),
    LevelBadge(
      level: 5,
      emoji: '🔋',
      title: 'Batterie Chargée',
      description: 'Tu es plein d\'énergie renouvelable !',
      rarity: 'Rare',
    ),

    // Novice (6-10)
    LevelBadge(
      level: 7,
      emoji: '☀️',
      title: 'Rayon Solaire',
      description: 'Ton énergie rayonne comme le soleil',
      rarity: 'Rare',
    ),
    LevelBadge(
      level: 10,
      emoji: '🌊',
      title: 'Vague Puissante',
      description: 'Tu génères une force hydraulique !',
      rarity: 'Épique',
    ),

    // Intermédiaire (11-20)
    LevelBadge(
      level: 12,
      emoji: '💨',
      title: 'Souffle Éolien',
      description: 'Le vent de la connaissance te porte',
      rarity: 'Rare',
    ),
    LevelBadge(
      level: 15,
      emoji: '🔥',
      title: 'Flamme Ardente',
      description: 'Ta passion pour l\'énergie brûle intensément',
      rarity: 'Épique',
    ),
    LevelBadge(
      level: 20,
      emoji: '♻️',
      title: 'Maître Recycleur',
      description: 'Tu es un champion de l\'économie circulaire !',
      rarity: 'Légendaire',
    ),

    // Avancé (21-35)
    LevelBadge(
      level: 25,
      emoji: '🌍',
      title: 'Gardien de la Terre',
      description: 'Tu protèges activement notre planète',
      rarity: 'Épique',
    ),
    LevelBadge(
      level: 30,
      emoji: '⚙️',
      title: 'Ingénieur Énergétique',
      description: 'Tu maîtrises les systèmes complexes',
      rarity: 'Légendaire',
    ),
    LevelBadge(
      level: 35,
      emoji: '🚀',
      title: 'Innovateur Spatial',
      description: 'Tes connaissances dépassent les limites !',
      rarity: 'Légendaire',
    ),

    // Expert (36-50)
    LevelBadge(
      level: 40,
      emoji: '💎',
      title: 'Diamant Énergétique',
      description: 'Tu es une ressource précieuse !',
      rarity: 'Mythique',
    ),
    LevelBadge(
      level: 45,
      emoji: '🏆',
      title: 'Champion de l\'Énergie',
      description: 'Tu domines le domaine énergétique',
      rarity: 'Mythique',
    ),
    LevelBadge(
      level: 50,
      emoji: '⭐',
      title: 'Étoile Suprême',
      description: 'Tu brilles parmi les plus grands !',
      rarity: 'Légendaire',
    ),

    // Maître (51+)
    LevelBadge(
      level: 60,
      emoji: '👑',
      title: 'Roi de l\'Énergie',
      description: 'Tu règnes sur le monde énergétique',
      rarity: 'Mythique',
    ),
    LevelBadge(
      level: 75,
      emoji: '🌟',
      title: 'Supernova',
      description: 'Ton éclat illumine l\'univers entier',
      rarity: 'Divin',
    ),
    LevelBadge(
      level: 100,
      emoji: '🔱',
      title: 'Dieu de l\'Énergie',
      description: 'Tu as atteint l\'ultime maîtrise !',
      rarity: 'Divin',
    ),
  ];

  /// Obtenir le badge pour un niveau donné
  LevelBadge? getBadgeForLevel(int level) {
    try {
      return badges.firstWhere((badge) => badge.level == level);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir tous les badges débloqués jusqu'à un niveau
  List<LevelBadge> getUnlockedBadges(int currentLevel) {
    return badges.where((badge) => badge.level <= currentLevel).toList();
  }

  /// Obtenir tous les badges encore verrouillés
  List<LevelBadge> getLockedBadges(int currentLevel) {
    return badges.where((badge) => badge.level > currentLevel).toList();
  }

  /// Vérifier si un badge a été débloqué lors d'un level up
  LevelBadge? checkNewBadge(int oldLevel, int newLevel) {
    if (newLevel > oldLevel) {
      return getBadgeForLevel(newLevel);
    }
    return null;
  }

  /// Obtenir le prochain badge à débloquer
  LevelBadge? getNextBadge(int currentLevel) {
    final lockedBadges = getLockedBadges(currentLevel);
    if (lockedBadges.isEmpty) return null;
    return lockedBadges.first;
  }

  /// Obtenir le dernier badge débloqué
  LevelBadge? getLastUnlockedBadge(int currentLevel) {
    final unlockedBadges = getUnlockedBadges(currentLevel);
    if (unlockedBadges.isEmpty) return null;
    return unlockedBadges.last;
  }

  /// Obtenir la couleur selon la rareté
  static int getColorByRarity(String rarity) {
    switch (rarity) {
      case 'Commun':
        return 0xFF9E9E9E; // Gris
      case 'Rare':
        return 0xFF2196F3; // Bleu
      case 'Épique':
        return 0xFF9C27B0; // Violet
      case 'Légendaire':
        return 0xFFFF9800; // Orange
      case 'Mythique':
        return 0xFFE91E63; // Rose
      case 'Divin':
        return 0xFFFFD700; // Or
      default:
        return 0xFF9E9E9E;
    }
  }

  /// Obtenir le nombre total de badges
  int get totalBadges => badges.length;

  /// Calculer le pourcentage de badges débloqués
  double getBadgeCompletionPercentage(int currentLevel) {
    final unlocked = getUnlockedBadges(currentLevel).length;
    return (unlocked / totalBadges) * 100;
  }
}

