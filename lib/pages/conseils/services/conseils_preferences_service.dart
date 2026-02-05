import 'package:shared_preferences/shared_preferences.dart';

/// Service centralisé pour lire/écrire les préférences liées aux conseils.
///
/// Objectif: éviter les divergences entre pages (Conseils/Rappels/Paramètres conseils)
/// en utilisant les mêmes clés SharedPreferences.
class ConseilsPreferencesService {
  static const String _keyHeatingType = 'heating_type'; // 'collectif' | 'individuel'
  static const String _keyHeatingEnergy = 'heating_energy'; // 'gaz' | 'electrique'

  Future<String?> getHeatingType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHeatingType);
  }

  Future<void> setHeatingType(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_keyHeatingType);
      return;
    }
    await prefs.setString(_keyHeatingType, value);
  }

  Future<String?> getHeatingEnergy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHeatingEnergy);
  }

  Future<void> setHeatingEnergy(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_keyHeatingEnergy);
      return;
    }
    await prefs.setString(_keyHeatingEnergy, value);
  }
}

