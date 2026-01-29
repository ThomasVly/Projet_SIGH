import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _userNameKey = 'user_name';
  static const String _creationDateKey = 'creation_date';

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

    // Sauvegarder la date de création seulement si elle n'existe pas déjà
    final existingDate = prefs.getString(_creationDateKey);
    if (existingDate == null) {
      await prefs.setString(_creationDateKey, DateTime.now().toIso8601String());
    }
  }

  /// Récupère le prénom de l'utilisateur
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'clara';
  }

  /// Récupère la date de création du compte
  static Future<DateTime> getCreationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_creationDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    // Par défaut, retourner la date actuelle
    return DateTime.now();
  }

  /// Récupère la date de création formatée pour l'affichage
  static Future<String> getFormattedCreationDate() async {
    final date = await getCreationDate();
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return 'Membre depuis ${months[date.month - 1]} ${date.year}';
  }

  /// Réinitialise l'onboarding (pour les tests ou la réinitialisation)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_creationDateKey);
  }

  /// Met à jour le prénom de l'utilisateur
  static Future<void> updateUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }
}

