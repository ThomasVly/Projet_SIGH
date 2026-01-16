import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _userNameKey = 'user_name';

  /// Vérifie si l'utilisateur a complété l'onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Marque l'onboarding comme complété et sauvegarde le prénom
  static Future<void> completeOnboarding(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    await prefs.setString(_userNameKey, userName);
  }

  /// Récupère le prénom de l'utilisateur
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Utilisateur';
  }

  /// Réinitialise l'onboarding (pour les tests ou la réinitialisation)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_userNameKey);
  }

  /// Met à jour le prénom de l'utilisateur
  static Future<void> updateUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }
}

