import '../models/user_profile.dart';

class UserExperienceService {
  // Singleton pattern
  static final UserExperienceService _instance = UserExperienceService._internal();
  factory UserExperienceService() => _instance;
  UserExperienceService._internal();

  // XP requis par niveau (peut être configuré)
  static const int baseXPPerLevel = 100;
  static const double xpMultiplier = 1.5;

  // Points d'expérience pour différentes actions
  static const int xpPerQuizCompleted = 20;
  static const int xpPerChallengeCompleted = 50;
  static const int xpPerTestCompleted = 30;
  static const int xpPerDailyLogin = 5;
  static const int xpPerTipRead = 2;

  /// Calculer l'XP maximum requis pour un niveau donné
  int calculateMaxXPForLevel(int level) {
    if (level <= 1) return baseXPPerLevel;
    return (baseXPPerLevel * (level * xpMultiplier)).round();
  }

  /// Ajouter de l'XP à l'utilisateur et vérifier le level up
  UserProfile addExperience(UserProfile user, int xpToAdd, {String? reason}) {
    int newXP = user.currentXP + xpToAdd;
    int newLevel = user.currentLevel;
    int maxXP = user.maxXP;

    // Vérifier si l'utilisateur monte de niveau
    while (newXP >= maxXP) {
      newXP -= maxXP;
      newLevel++;
      maxXP = calculateMaxXPForLevel(newLevel);
    }

    return user.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      maxXP: maxXP,
    );
  }

  /// Ajouter XP pour un quiz complété
  UserProfile onQuizCompleted(UserProfile user) {
    final updatedUser = addExperience(user, xpPerQuizCompleted, reason: 'Quiz complété');
    return updatedUser.copyWith(
      quizCount: user.quizCount + 1,
    );
  }

  /// Ajouter XP pour un défi complété
  UserProfile onChallengeCompleted(UserProfile user) {
    final updatedUser = addExperience(user, xpPerChallengeCompleted, reason: 'Défi complété');
    return updatedUser.copyWith(
      challengeCount: user.challengeCount + 1,
    );
  }

  /// Ajouter XP pour un test complété
  UserProfile onTestCompleted(UserProfile user) {
    final updatedUser = addExperience(user, xpPerTestCompleted, reason: 'Test complété');
    return updatedUser.copyWith(
      totalTests: user.totalTests + 1,
    );
  }

  /// Ajouter XP pour connexion quotidienne
  UserProfile onDailyLogin(UserProfile user) {
    final updatedUser = addExperience(user, xpPerDailyLogin, reason: 'Connexion quotidienne');
    return updatedUser.copyWith(
      loginStreak: user.loginStreak + 1,
    );
  }

  /// Ajouter XP pour lecture d'un conseil/article
  UserProfile onTipRead(UserProfile user) {
    return addExperience(user, xpPerTipRead, reason: 'Conseil lu');
  }

  /// Ajouter XP pour lecture d'un article
  UserProfile onArticleRead(UserProfile user) {
    final updatedUser = addExperience(user, xpPerTipRead, reason: 'Article lu');
    return updatedUser.copyWith(
      articleCount: user.articleCount + 1,
    );
  }

  /// Ajouter de l'énergie économisée (en kWh)
  UserProfile addEnergySaved(UserProfile user, double kwh) {
    return user.copyWith(
      energySaved: user.energySaved + kwh,
    );
  }

  /// Ajouter un badge
  UserProfile addBadge(UserProfile user) {
    return user.copyWith(
      badges: user.badges + 1,
    );
  }

  /// Vérifier si l'utilisateur a gagné un niveau
  bool hasLeveledUp(UserProfile oldUser, UserProfile newUser) {
    return newUser.currentLevel > oldUser.currentLevel;
  }

  /// Obtenir le titre du niveau
  String getLevelTitle(int level) {
    if (level <= 5) return 'Débutant';
    if (level <= 10) return 'Novice';
    if (level <= 20) return 'Intermédiaire';
    if (level <= 35) return 'Avancé';
    if (level <= 50) return 'Expert';
    return 'Maître';
  }
}

