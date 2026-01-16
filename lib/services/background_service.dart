import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../pages/Rappel/services/weather_service.dart';
import '../pages/Rappel/models/reminder.dart';

// Nom de la tâche unique
const String updateWeatherTask = "updateWeatherTask";

// Instance des notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Point d'entrée pour le background (doit être top-level ou static)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case updateWeatherTask:
        print("Workmanager: Exécution de la tâche météo");
        try {
          // Initialiser les notifications si nécessaire (pour le contexte background)
          const AndroidInitializationSettings initializationSettingsAndroid =
              AndroidInitializationSettings('@mipmap/ic_launcher');
          const InitializationSettings initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);
          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
          );

          // Vérifier si la météo est activée
          final prefs = await SharedPreferences.getInstance();
          final bool isEnabled =
              prefs.getBool('weather_location_enabled') ?? false;

          // Vérification horaire et fréquence
          final now = DateTime.now();
          final hour = now.hour;

          // Définition des créneaux (08h et 19h)
          final isMorningSlot = hour == 8; // Entre 8h00 et 8h59
          final isEveningSlot = hour == 19; // Entre 19h00 et 19h59

          if (!isMorningSlot && !isEveningSlot) {
            print("Hors créneau horaire (Actuel: $hour h). Pas de notif.");
            return Future.value(true);
          }

          // Vérifier si déjà notifié aujourd'hui pour ce créneau
          final lastNotifKey = isMorningSlot
              ? 'last_weather_notif_morning'
              : 'last_weather_notif_evening';
          final lastNotifDay = prefs.getInt(lastNotifKey) ?? -1;

          if (lastNotifDay == now.day) {
            print("Déjà notifié aujourd'hui pour ce créneau ($lastNotifKey).");
            return Future.value(true);
          }

          if (isEnabled) {
            final weatherService = WeatherService();
            // Note: En background sur Android, la géolocalisation peut être restreinte.
            // On utilise un ID arbitraire pour la génération
            final reminders = await weatherService.generateWeatherReminders(
              9999,
            );

            bool notificationSent = false;
            for (var reminder in reminders) {
              // Filtrer pour ne notifier que les alertes importantes
              if (reminder.title.contains("Alerte") ||
                  reminder.title.contains("Vent") ||
                  reminder.title.contains("Météo")) {
                await _showNotification(reminder);
                notificationSent = true;
              }
            }

            // Si une notification a été envoyée, on sauvegarde la date
            if (notificationSent) {
              await prefs.setInt(lastNotifKey, now.day);
            }
          }
        } catch (e) {
          print("Erreur Workmanager: $e");
        }
        break;
    }
    return Future.value(true);
  });
}

Future<void> _showNotification(Reminder reminder) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'weather_channel', // id
        'Météo', // title
        channelDescription: 'Notifications liées à la météo',
        importance: Importance.max,
        priority: Priority.high,
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    reminder.id ?? 0,
    reminder.title,
    reminder.description,
    platformChannelSpecifics,
  );
}

class BackgroundService {
  Future<void> initialize() async {
    // Supprimé (on autorise l'init des notifs même sur Web)
    // if (kIsWeb) return;

    // Init Notifications (Frontend)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (kIsWeb) return; // Bloquer Workmanager sur Web

    // Init Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Pour voir les logs en dev
    );
  }

  Future<void> registerPeriodicTask() async {
    if (kIsWeb) return;
    try {
      await Workmanager().registerPeriodicTask(
        "1", // unique name
        updateWeatherTask,
        frequency: const Duration(hours: 1), // Minimum 15 min sur Android
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (e) {
      debugPrint("Erreur registerPeriodicTask: $e");
    }
  }

  Future<void> cancelAllTasks() async {
    if (kIsWeb) return;
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      debugPrint("Erreur cancelAllTasks: $e");
    }
  }

  // Méthode publique pour envoyer une notification (utile pour les tests Web)
  Future<void> sendNotification(Reminder reminder) async {
    await _showNotification(reminder);
  }
}
