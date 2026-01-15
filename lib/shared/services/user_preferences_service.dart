import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Service pour gérer la persistance des données utilisateur avec SharedPreferences
class UserPreferencesService {
  static const String _keyUserProfile = 'user_profile';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyMemberSince = 'member_since';
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyCurrentXP = 'current_xp';
  static const String _keyMaxXP = 'max_xp';
  static const String _keyTotalTests = 'total_tests';
  static const String _keyQuizCount = 'quiz_count';
  static const String _keyBadges = 'badges';
  static const String _keyAvatarEmoji = 'avatar_emoji';

  /// Sauvegarder le profil utilisateur
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder chaque champ individuellement pour plus de flexibilité
      await prefs.setString(_keyUserId, profile.id);
      await prefs.setString(_keyUserName, profile.userName);
      await prefs.setString(_keyMemberSince, profile.memberSince);
      await prefs.setInt(_keyCurrentLevel, profile.currentLevel);
      await prefs.setInt(_keyCurrentXP, profile.currentXP);
      await prefs.setInt(_keyMaxXP, profile.maxXP);
      await prefs.setInt(_keyTotalTests, profile.totalTests);
      await prefs.setInt(_keyQuizCount, profile.quizCount);
      await prefs.setInt(_keyBadges, profile.badges);
      await prefs.setString(_keyAvatarEmoji, profile.avatarEmoji);

      // Sauvegarder aussi en JSON pour backup
      final jsonString = jsonEncode(profile.toMap());
      await prefs.setString(_keyUserProfile, jsonString);

      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde du profil: $e');
      return false;
    }
  }

  /// Charger le profil utilisateur
  Future<UserProfile?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Essayer de charger depuis les clés individuelles
      final userId = prefs.getString(_keyUserId);
      if (userId == null) {
        // Pas de profil sauvegardé
        return null;
      }

      final userName = prefs.getString(_keyUserName) ?? 'Utilisateur';
      final memberSince = prefs.getString(_keyMemberSince) ??
          'Membre depuis ${_formatDate(DateTime.now())}';
      final currentLevel = prefs.getInt(_keyCurrentLevel) ?? 1;
      final currentXP = prefs.getInt(_keyCurrentXP) ?? 0;
      final maxXP = prefs.getInt(_keyMaxXP) ?? 100;
      final totalTests = prefs.getInt(_keyTotalTests) ?? 0;
      final quizCount = prefs.getInt(_keyQuizCount) ?? 0;
      final badges = prefs.getInt(_keyBadges) ?? 0;
      final avatarEmoji = prefs.getString(_keyAvatarEmoji) ?? '⚡';

      return UserProfile(
        id: userId,
        userName: userName,
        memberSince: memberSince,
        currentLevel: currentLevel,
        currentXP: currentXP,
        maxXP: maxXP,
        totalTests: totalTests,
        quizCount: quizCount,
        badges: badges,
        avatarEmoji: avatarEmoji,
      );
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');

      // Essayer de charger depuis le JSON backup
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString(_keyUserProfile);
        if (jsonString != null) {
          final map = jsonDecode(jsonString) as Map<String, dynamic>;
          return UserProfile.fromMap(map);
        }
      } catch (e2) {
        print('Erreur lors du chargement du backup JSON: $e2');
      }

      return null;
    }
  }

  /// Supprimer le profil utilisateur
  Future<bool> deleteUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyUserProfile);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyMemberSince);
      await prefs.remove(_keyCurrentLevel);
      await prefs.remove(_keyCurrentXP);
      await prefs.remove(_keyMaxXP);
      await prefs.remove(_keyTotalTests);
      await prefs.remove(_keyQuizCount);
      await prefs.remove(_keyBadges);
      await prefs.remove(_keyAvatarEmoji);

      return true;
    } catch (e) {
      print('Erreur lors de la suppression du profil: $e');
      return false;
    }
  }

  /// Vérifier si un profil existe
  Future<bool> hasUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyUserId);
    } catch (e) {
      print('Erreur lors de la vérification du profil: $e');
      return false;
    }
  }

  /// Mettre à jour seulement l'XP et le niveau
  Future<bool> updateXPAndLevel(int xp, int level, int maxXP) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCurrentXP, xp);
      await prefs.setInt(_keyCurrentLevel, level);
      await prefs.setInt(_keyMaxXP, maxXP);
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour XP: $e');
      return false;
    }
  }

  /// Mettre à jour seulement l'avatar
  Future<bool> updateAvatar(String emoji) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAvatarEmoji, emoji);
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour avatar: $e');
      return false;
    }
  }

  /// Incrémenter le compteur de quiz
  Future<bool> incrementQuizCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyQuizCount) ?? 0;
      await prefs.setInt(_keyQuizCount, current + 1);
      return true;
    } catch (e) {
      print('Erreur lors de l\'incrémentation quiz: $e');
      return false;
    }
  }

  /// Incrémenter le compteur de tests
  Future<bool> incrementTestCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyTotalTests) ?? 0;
      await prefs.setInt(_keyTotalTests, current + 1);
      return true;
    } catch (e) {
      print('Erreur lors de l\'incrémentation tests: $e');
      return false;
    }
  }

  /// Incrémenter le compteur de badges
  Future<bool> incrementBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyBadges) ?? 0;
      await prefs.setInt(_keyBadges, current + 1);
      return true;
    } catch (e) {
      print('Erreur lors de l\'incrémentation badges: $e');
      return false;
    }
  }

  /// Formater une date en français
  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Réinitialiser toutes les préférences (pour debug)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print('Erreur lors du clear: $e');
      return false;
    }
  }
}

