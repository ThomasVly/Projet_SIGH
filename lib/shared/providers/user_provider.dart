import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/user_experience_service.dart';
import '../services/level_badge_service.dart';
import '../services/user_preferences_service.dart';


class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  final UserExperienceService _xpService = UserExperienceService();
  final LevelBadgeService _badgeService = LevelBadgeService();
  final UserPreferencesService _prefsService = UserPreferencesService();

  // Callback pour afficher le badge débloqué
  Function(LevelBadge)? onBadgeUnlocked;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserProfile? get userProfile => _userProfile;

  // Initialiser l'utilisateur (charge depuis SharedPreferences ou crée nouveau)
  Future<void> initializeUser({
    required String id,
    required String userName,
    required String memberSince,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Essayer de charger le profil existant
      final savedProfile = await _prefsService.loadUserProfile();

      if (savedProfile != null) {
        // Profil trouvé, le charger
        _userProfile = savedProfile;
        debugPrint('✅ Profil chargé depuis SharedPreferences');
      } else {
        // Pas de profil sauvegardé, en créer un nouveau
        _userProfile = UserProfile(
          id: id,
          userName: userName,
          memberSince: memberSince,
          currentLevel: 1,
          currentXP: 0,
          maxXP: _xpService.calculateMaxXPForLevel(1),
        );

        // Sauvegarder le nouveau profil
        await _prefsService.saveUserProfile(_userProfile!);
        debugPrint('✅ Nouveau profil créé et sauvegardé');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation: $e');
      // En cas d'erreur, créer un profil par défaut
      _userProfile = UserProfile(
        id: id,
        userName: userName,
        memberSince: memberSince,
        currentLevel: 1,
        currentXP: 0,
        maxXP: _xpService.calculateMaxXPForLevel(1),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger l'utilisateur depuis la base de données
  void loadUser(UserProfile user) {
    _userProfile = user;
    notifyListeners();
  }

  // Mettre à jour l'utilisateur
  void updateUser(UserProfile user) {
    _userProfile = user;
    notifyListeners();
  }

  // Ajouter de l'XP
  Future<void> addExperience(int xp, {String? reason}) async {
    if (_userProfile == null) return;

    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.addExperience(_userProfile!, xp, reason: reason);

    // Vérifier si l'utilisateur a monté de niveau
    if (_userProfile!.currentLevel > oldLevel) {
      debugPrint('Level Up! Nouveau niveau: ${_userProfile!.currentLevel}');

      // Vérifier si un badge a été débloqué
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null && onBadgeUnlocked != null) {
        onBadgeUnlocked!(newBadge);
      }
    }

    notifyListeners();

    // Sauvegarder automatiquement dans SharedPreferences
    await _prefsService.saveUserProfile(_userProfile!);
  }

  // Actions spécifiques
  Future<void> onQuizCompleted() async {
    if (_userProfile == null) return;
    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.onQuizCompleted(_userProfile!);

    // Vérifier niveau supérieur
    if (_userProfile!.currentLevel > oldLevel) {

      // Vérifier badge de niveau
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null) {
        if (onBadgeUnlocked != null) {
          onBadgeUnlocked!(newBadge);
        }
      }
    }

    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  Future<void> onChallengeCompleted() async {
    if (_userProfile == null) return;
    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.onChallengeCompleted(_userProfile!);

    // Vérifier niveau supérieur
    if (_userProfile!.currentLevel > oldLevel) {
      // Vérifier badge de niveau
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null) {
        if (onBadgeUnlocked != null) {
          onBadgeUnlocked!(newBadge);
        }
      }
    }

    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  Future<void> onTestCompleted() async {
    if (_userProfile == null) return;
    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.onTestCompleted(_userProfile!);

    // Vérifier badge
    if (_userProfile!.currentLevel > oldLevel) {
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null && onBadgeUnlocked != null) {
        onBadgeUnlocked!(newBadge);
      }
    }

    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  Future<void> onDailyLogin() async {
    if (_userProfile == null) return;
    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.onDailyLogin(_userProfile!);

    // Vérifier badge
    if (_userProfile!.currentLevel > oldLevel) {
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null && onBadgeUnlocked != null) {
        onBadgeUnlocked!(newBadge);
      }
    }

    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  Future<void> onTipRead() async {
    if (_userProfile == null) return;
    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.onTipRead(_userProfile!);

    // Vérifier badge
    if (_userProfile!.currentLevel > oldLevel) {
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null && onBadgeUnlocked != null) {
        onBadgeUnlocked!(newBadge);
      }
    }

    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  Future<void> addBadge() async {
    if (_userProfile == null) return;
    _userProfile = _xpService.addBadge(_userProfile!);
    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  // Ajouter un article lu
  Future<void> onArticleRead() async {
    if (_userProfile == null) return;
    final oldLevel = _userProfile!.currentLevel;
    _userProfile = _xpService.onArticleRead(_userProfile!);

    // Vérifier badge
    if (_userProfile!.currentLevel > oldLevel) {
      final newBadge = _badgeService.checkNewBadge(oldLevel, _userProfile!.currentLevel);
      if (newBadge != null && onBadgeUnlocked != null) {
        onBadgeUnlocked!(newBadge);
      }
    }

    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  // Ajouter de l'énergie économisée (en kWh)
  Future<void> addEnergySaved(double kwh) async {
    if (_userProfile == null) return;
    _userProfile = _xpService.addEnergySaved(_userProfile!, kwh);
    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  // Changer l'avatar
  Future<void> changeAvatar(String emoji) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(avatarEmoji: emoji);
    notifyListeners();
    await _prefsService.saveUserProfile(_userProfile!);
  }

  // Réinitialiser le profil (pour debug/test)
  Future<void> resetProfile() async {
    await _prefsService.deleteUserProfile();
    _userProfile = null;
    notifyListeners();
  }

  // Obtenir le titre du niveau
  String getLevelTitle() {
    if (_userProfile == null) return 'Débutant';
    return _xpService.getLevelTitle(_userProfile!.currentLevel);
  }
}

