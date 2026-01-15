import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/reminder.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Détermine la position actuelle de l'utilisateur
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Les permissions de localisation sont refusées définitivement.',
      );
    }

    // Récupérer la position avec une précision moyenne pour économiser la batterie
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// Récupère la météo actuelle pour la position donnée
  Future<Map<String, dynamic>> getWeather() async {
    try {
      final position = await _determinePosition();

      final url = Uri.parse(
        '$_baseUrl?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération de la météo');
      }
    } catch (e) {
      throw Exception('Impossible de récupérer la météo: $e');
    }
  }

  /// Génère des suggestions de rappels basées sur la météo
  /// Retourne une liste de rappels potentiels à ajouter ou mettre à jour
  Future<List<Reminder>> generateWeatherReminders(int startId) async {
    try {
      final weatherData = await getWeather();
      final current = weatherData['current'];
      final double temp = current['temperature_2m'];
      final double windSpeed = current['wind_speed_10m'];

      List<Reminder> weatherReminders = [];
      int currentId = startId;

      // Règle 1: Froid (< 18°C) -> Conseils Chauffage
      if (temp < 18) {
        weatherReminders.add(
          Reminder(
            id: currentId++,
            title: "Alerte Froid ($temp°C)",
            description:
                "Il fait froid dehors. Fermez les volets dès la tombée de la nuit pour conserver la chaleur.",
            type: ReminderType.weatherLocation,
            frequency: ReminderFrequency.daily,
            isActive: true,
            scheduledTime: DateTime.now().add(
              const Duration(hours: 1),
            ), // Rappel pour bientôt
          ),
        );
      }
      // Règle 2: Chaud (> 26°C) -> Conseils Fraîcheur
      else if (temp > 26) {
        weatherReminders.add(
          Reminder(
            id: currentId++,
            title: "Alerte Chaleur ($temp°C)",
            description:
                "Température élevée. Gardez les volets fermés en journée pour maintenir la fraîcheur sans climatisation.",
            type: ReminderType.weatherLocation,
            frequency: ReminderFrequency.daily,
            isActive: true,
            scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
          ),
        );
      }

      // Règle 3: Vent fort (> 25 km/h) -> Isolation
      if (windSpeed > 25) {
        weatherReminders.add(
          Reminder(
            id: currentId++,
            title: "Vent fort ($windSpeed km/h)",
            description:
                "Vent important détecté. Vérifiez la fermeture des portes et fenêtres pour éviter les courants d'air.",
            type: ReminderType.weatherLocation,
            frequency: ReminderFrequency.daily,
            isActive: true,
            scheduledTime: DateTime.now().add(const Duration(minutes: 45)),
          ),
        );
      }

      // Si aucune condition extrême, un rappel informatif générique (optionnel)
      if (weatherReminders.isEmpty) {
        weatherReminders.add(
          Reminder(
            id: currentId++,
            title: "Météo locale ($temp°C)",
            description:
                "Météo clémente aujourd'hui. Profitez-en pour aérer votre logement 10 minutes.",
            type: ReminderType.weatherLocation,
            frequency: ReminderFrequency.daily,
            isActive: true,
          ),
        );
      }

      return weatherReminders;
    } catch (e) {
      print("Erreur service météo: $e");
      // En cas d'erreur de récupération (ex: pas internet), on renvoie une liste vide pour ne pas crasher
      return [];
    }
  }
}
