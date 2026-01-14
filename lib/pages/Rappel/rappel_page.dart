import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/reminder.dart';

// Couleurs du thème
const Color kPrimaryDark = Color(0xFF003366);
const Color kPrimaryLight = Color(0xFF0055AA);

// Point d'entrée pour tester directement cette page
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryDark,
          primary: kPrimaryDark,
          secondary: kPrimaryLight,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const RappelPage(),
    ),
  );
}

// ============ PAGE PRINCIPALE ============

class RappelPage extends StatefulWidget {
  const RappelPage({super.key});

  @override
  State<RappelPage> createState() => _RappelPageState();
}

class _RappelPageState extends State<RappelPage> {
  List<Reminder> _reminders = [];
  int _nextId = 1;

  // États pour les switches et choix
  bool _weatherLocationEnabled = false;
  bool _consumptionAlertEnabled = false;
  bool _challengesEnabled = false;
  String? _heatingType; // 'collectif' ou 'individuel'
  String? _heatingEnergy; // 'gaz' ou 'electrique'

  // États pour les heures creuses
  bool? _hasOffPeakHours; // null = pas encore répondu, true = oui, false = non
  List<Map<String, TimeOfDay>> _offPeakSlots = []; // Liste des plages horaires
  ReminderFrequency _offPeakFrequency = ReminderFrequency.daily;
  List<int> _offPeakDays = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ]; // 1=Lun, 7=Dim - jours actifs pour quotidien
  int _offPeakWeekday = 1; // Jour de la semaine pour hebdomadaire (1=Lun)

  final List<_SuggestedAction> _suggestions = [
    _SuggestedAction(
      id: 'off_peak_config',
      title: 'Heures creuses',
      description: 'Configurez vos plages d\'heures creuses',
      type: ReminderType.offPeakHours,
      icon: '⏰',
      isPopular: true,
    ),
    _SuggestedAction(
      id: 'consumption',
      title: 'Consommation anormale',
      description: 'Soyez alerté en cas de pic de consommation',
      type: ReminderType.highConsumption,
      icon: '⚡',
      isPopular: true,
    ),
    _SuggestedAction(
      id: 'weather',
      title: 'Météo & Localisation',
      description: 'Autoriser l\'accès à la météo et votre localisation',
      type: ReminderType.weatherLocation,
      icon: '🌤️',
      isPopular: true,
    ),
    _SuggestedAction(
      id: 'equipment',
      title: 'Mes équipements',
      description: 'Gérer vos appareils depuis votre inventaire',
      type: ReminderType.equipmentUsage,
      icon: '🔌',
    ),
    _SuggestedAction(
      id: 'heating_type',
      title: 'Type de chauffage',
      description: 'Chauffage collectif ou individuel',
      type: ReminderType.heatingType,
      icon: '👥',
    ),
    _SuggestedAction(
      id: 'heating_energy',
      title: 'Énergie de chauffage',
      description: 'Chauffage au gaz ou électrique',
      type: ReminderType.heatingEnergy,
      icon: '♨️',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Charger les préférences sauvegardées
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    debugPrint('=== CHARGEMENT DES PREFERENCES ===');
    debugPrint(
      'weather_location_enabled: ${prefs.getBool('weather_location_enabled')}',
    );
    debugPrint(
      'consumption_alert_enabled: ${prefs.getBool('consumption_alert_enabled')}',
    );
    debugPrint('heating_type: ${prefs.getString('heating_type')}');
    debugPrint('heating_energy: ${prefs.getString('heating_energy')}');
    debugPrint('has_off_peak_hours: ${prefs.getBool('has_off_peak_hours')}');
    debugPrint('reminders: ${prefs.getString('reminders')}');

    setState(() {
      // Météo & Localisation
      _weatherLocationEnabled =
          prefs.getBool('weather_location_enabled') ?? false;

      // Alerte consommation
      _consumptionAlertEnabled =
          prefs.getBool('consumption_alert_enabled') ?? false;

      // Défis
      _challengesEnabled = prefs.getBool('challenges_enabled') ?? false;

      // Type de chauffage
      _heatingType = prefs.getString('heating_type');

      // Énergie de chauffage
      _heatingEnergy = prefs.getString('heating_energy');

      // Heures creuses
      final hasHC = prefs.getBool('has_off_peak_hours');
      _hasOffPeakHours = hasHC;

      // Plages horaires
      final slotsJson = prefs.getString('off_peak_slots');
      if (slotsJson != null && slotsJson.isNotEmpty) {
        try {
          final List<dynamic> slots = jsonDecode(slotsJson);
          _offPeakSlots = slots.map((slot) {
            return {
              'start': TimeOfDay(
                hour: slot['startHour'],
                minute: slot['startMinute'],
              ),
              'end': TimeOfDay(
                hour: slot['endHour'],
                minute: slot['endMinute'],
              ),
            };
          }).toList();
        } catch (e) {
          debugPrint('Erreur parsing slots: $e');
        }
      }

      // Fréquence et jours des heures creuses
      final freqStr = prefs.getString('off_peak_frequency');
      if (freqStr != null) {
        _offPeakFrequency = ReminderFrequency.values.firstWhere(
          (f) => f.name == freqStr,
          orElse: () => ReminderFrequency.daily,
        );
      }
      final daysJson = prefs.getString('off_peak_days');
      if (daysJson != null) {
        _offPeakDays = List<int>.from(jsonDecode(daysJson));
      }
      _offPeakWeekday = prefs.getInt('off_peak_weekday') ?? 1;

      // Charger les rappels sauvegardés
      final remindersJson = prefs.getString('reminders');
      if (remindersJson != null && remindersJson.isNotEmpty) {
        try {
          final List<dynamic> remindersList = jsonDecode(remindersJson);
          _reminders = remindersList.map((r) => Reminder.fromJson(r)).toList();
          if (_reminders.isNotEmpty) {
            _nextId =
                _reminders
                    .map((r) => r.id ?? 0)
                    .reduce((a, b) => a > b ? a : b) +
                1;
          }
          debugPrint('Chargé ${_reminders.length} rappels');
        } catch (e) {
          debugPrint('Erreur parsing reminders: $e');
        }
      }
    });

    debugPrint('=== FIN CHARGEMENT ===');
  }

  /// Sauvegarder les préférences
  Future<void> _savePreferences() async {
    debugPrint('=== SAUVEGARDE DES PREFERENCES ===');
    debugPrint('weather_location_enabled: $_weatherLocationEnabled');
    debugPrint('consumption_alert_enabled: $_consumptionAlertEnabled');
    debugPrint('heating_type: $_heatingType');
    debugPrint('heating_energy: $_heatingEnergy');
    debugPrint('has_off_peak_hours: $_hasOffPeakHours');
    debugPrint('reminders count: ${_reminders.length}');

    final prefs = await SharedPreferences.getInstance();

    // Météo & Localisation
    await prefs.setBool('weather_location_enabled', _weatherLocationEnabled);

    // Alerte consommation
    await prefs.setBool('consumption_alert_enabled', _consumptionAlertEnabled);

    // Défis
    await prefs.setBool('challenges_enabled', _challengesEnabled);

    // Type de chauffage
    if (_heatingType != null) {
      await prefs.setString('heating_type', _heatingType!);
    }

    // Énergie de chauffage
    if (_heatingEnergy != null) {
      await prefs.setString('heating_energy', _heatingEnergy!);
    }

    // Heures creuses
    if (_hasOffPeakHours != null) {
      await prefs.setBool('has_off_peak_hours', _hasOffPeakHours!);
    }

    // Plages horaires
    final slotsJson = jsonEncode(
      _offPeakSlots.map((slot) {
        return {
          'startHour': slot['start']!.hour,
          'startMinute': slot['start']!.minute,
          'endHour': slot['end']!.hour,
          'endMinute': slot['end']!.minute,
        };
      }).toList(),
    );
    await prefs.setString('off_peak_slots', slotsJson);

    // Fréquence et jours des heures creuses
    await prefs.setString('off_peak_frequency', _offPeakFrequency.name);
    await prefs.setString('off_peak_days', jsonEncode(_offPeakDays));
    await prefs.setInt('off_peak_weekday', _offPeakWeekday);

    // Sauvegarder les rappels
    final remindersJson = jsonEncode(
      _reminders.map((r) => r.toJson()).toList(),
    );
    await prefs.setString('reminders', remindersJson);

    debugPrint('=== SAUVEGARDE TERMINEE ===');

    // Vérification immédiate
    debugPrint(
      'Vérification: weather=${prefs.getBool('weather_location_enabled')}',
    );
  }

  /// Créer les rappels pour les heures creuses basés sur les plages configurées
  void _createOffPeakReminders() {
    // Supprimer les anciens rappels d'heures creuses
    _reminders.removeWhere(
      (r) =>
          r.type == ReminderType.offPeakHours ||
          r.type == ReminderType.peakHours,
    );

    if (_hasOffPeakHours == true && _offPeakSlots.isNotEmpty) {
      for (int i = 0; i < _offPeakSlots.length; i++) {
        final slot = _offPeakSlots[i];
        final startTime = slot['start']!;
        final endTime = slot['end']!;
        final plageNum = _offPeakSlots.length > 1 ? ' (plage ${i + 1})' : '';

        // Rappel début heures creuses
        _reminders.add(
          Reminder(
            id: _nextId++,
            title: 'Début heures creuses$plageNum',
            description:
                'Les heures creuses commencent à ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
            type: ReminderType.offPeakHours,
            frequency: _offPeakFrequency,
            scheduledTime: DateTime(
              2024,
              1,
              1,
              startTime.hour,
              startTime.minute,
            ),
            isActive: true,
          ),
        );

        // Rappel fin heures creuses (15 min avant)
        final endHour = endTime.hour == 0 && endTime.minute < 15
            ? 23
            : (endTime.minute < 15 ? endTime.hour - 1 : endTime.hour);
        final endMinute = endTime.minute < 15
            ? 60 - (15 - endTime.minute)
            : endTime.minute - 15;

        _reminders.add(
          Reminder(
            id: _nextId++,
            title: 'Fin heures creuses$plageNum',
            description:
                'Les heures creuses se terminent dans 15 min (à ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')})',
            type: ReminderType.peakHours,
            frequency: _offPeakFrequency,
            scheduledTime: DateTime(2024, 1, 1, endHour, endMinute),
            isActive: true,
          ),
        );
      }
    }

    setState(() {});
  }

  /// Créer ou supprimer le rappel météo selon l'état du switch
  void _updateWeatherReminder() {
    // Supprimer l'ancien rappel météo s'il existe
    _reminders.removeWhere((r) => r.type == ReminderType.weatherLocation);

    if (_weatherLocationEnabled) {
      _reminders.add(
        Reminder(
          id: _nextId++,
          title: 'Conseils météo',
          description:
              'Recevez des conseils personnalisés basés sur la météo de votre localisation',
          type: ReminderType.weatherLocation,
          frequency: ReminderFrequency.daily,
          isActive: true,
        ),
      );
    }

    setState(() {});
  }

  /// Créer ou supprimer le rappel de consommation anormale
  void _updateConsumptionReminder(bool enabled) {
    // Supprimer l'ancien rappel s'il existe
    _reminders.removeWhere((r) => r.type == ReminderType.highConsumption);

    if (enabled) {
      _reminders.add(
        Reminder(
          id: _nextId++,
          title: 'Alerte consommation',
          description: 'Soyez alerté en cas de pic de consommation anormale',
          type: ReminderType.highConsumption,
          frequency: ReminderFrequency.realtime,
          isActive: true,
        ),
      );
    }

    setState(() {});
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Gérer mes rappels',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Heures creuses
            _buildOffPeakHoursCard(
              _SuggestedAction(
                id: 'off_peak_config',
                title: 'Heures creuses',
                description: 'Configurez vos plages d\'heures creuses',
                type: ReminderType.offPeakHours,
                icon: '⏰',
              ),
              colorScheme,
            ),

            // Météo
            _buildWeatherLocationCard(
              _SuggestedAction(
                id: 'weather',
                title: 'Météo',
                description: 'Recevoir des conseils basés sur la météo',
                type: ReminderType.weatherLocation,
                icon: '🌤️',
              ),
              colorScheme,
            ),

            // Défis
            _buildChallengesCard(colorScheme),

            const SizedBox(height: 16),

            // Section : Autres configurations
            _buildSectionHeader('Autres configurations', Icons.tune),

            // Chauffage électrique
            _buildHeatingEnergyCard(
              _SuggestedAction(
                id: 'heating_energy',
                title: 'Chauffage électrique',
                description:
                    'Activer les conseils si vous avez un chauffage électrique',
                type: ReminderType.heatingEnergy,
                icon: '⚡',
              ),
              colorScheme,
            ),

            // Chauffage individuel
            _buildHeatingTypeCard(
              _SuggestedAction(
                id: 'heating_type',
                title: 'Chauffage individuel',
                description:
                    'Activer les conseils si vous avez un chauffage individuel',
                type: ReminderType.heatingType,
                icon: '🏠',
              ),
              colorScheme,
            ),

            // Rappel pour un appareil
            _buildEquipmentCard(
              _SuggestedAction(
                id: 'equipment',
                title: 'Rappel appareil',
                description: 'Créer un rappel pour un appareil spécifique',
                type: ReminderType.equipmentUsage,
                icon: '🔌',
              ),
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte pour les défis
  Widget _buildChallengesCard(ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.3),
                        Colors.deepPurple.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('🎯', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Défis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Recevoir des notifications de défis mensuels',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _challengesEnabled,
                  onChanged: (value) {
                    setState(() => _challengesEnabled = value);
                    _savePreferences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Notifications de défis activées'
                              : 'Notifications de défis désactivées',
                        ),
                      ),
                    );
                  },
                  activeColor: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(_SuggestedAction action) {
    final colorScheme = Theme.of(context).colorScheme;

    // Cas spécial : Heures creuses avec configuration des plages
    if (action.type == ReminderType.offPeakHours) {
      return _buildOffPeakHoursCard(action, colorScheme);
    }

    // Cas spécial : Météo & Localisation avec switch
    if (action.type == ReminderType.weatherLocation) {
      return _buildWeatherLocationCard(action, colorScheme);
    }

    // Cas spécial : Équipements - navigation vers autre page
    if (action.type == ReminderType.equipmentUsage) {
      return _buildEquipmentCard(action, colorScheme);
    }

    // Cas spécial : Type de chauffage (collectif/individuel)
    if (action.type == ReminderType.heatingType) {
      return _buildHeatingTypeCard(action, colorScheme);
    }

    // Cas spécial : Énergie de chauffage (gaz/électrique)
    if (action.type == ReminderType.heatingEnergy) {
      return _buildHeatingEnergyCard(action, colorScheme);
    }

    // Cas spécial : Alerte consommation avec switch
    if (action.type == ReminderType.highConsumption) {
      return _buildConsumptionCard(action, colorScheme);
    }

    // Carte normale avec personnalisation
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _createFromSuggestion(action),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    action.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (action.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Populaire',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 18, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Carte simplifiée pour heures creuses avec rappels générés en dessous
  Widget _buildOffPeakHoursCard(
    _SuggestedAction action,
    ColorScheme colorScheme,
  ) {
    String subtitle = 'Configurer vos heures creuses';
    if (_hasOffPeakHours == true && _offPeakSlots.isNotEmpty) {
      final slot = _offPeakSlots.first;
      subtitle =
          '${slot['start']!.format(context)} - ${slot['end']!.format(context)}';
      if (_offPeakSlots.length > 1) {
        final slot2 = _offPeakSlots[1];
        subtitle +=
            ' • ${slot2['start']!.format(context)} - ${slot2['end']!.format(context)}';
      }
    } else if (_hasOffPeakHours == false) {
      subtitle = 'Pas d\'heures creuses';
    }

    // Récupérer les rappels d'heures creuses
    final offPeakReminders = _reminders
        .where(
          (r) =>
              r.type == ReminderType.offPeakHours ||
              r.type == ReminderType.peakHours,
        )
        .toList();

    return Column(
      children: [
        // Carte principale
        Card(
          elevation: _hasOffPeakHours == true ? 2 : 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _hasOffPeakHours == true
                ? BorderSide(color: colorScheme.primary.withOpacity(0.3))
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _showOffPeakConfigDialog(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _hasOffPeakHours == true
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        action.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: _hasOffPeakHours == true
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _hasOffPeakHours == true,
                    onChanged: (value) {
                      setState(() {
                        _hasOffPeakHours = value;
                        if (value && _offPeakSlots.isEmpty) {
                          _offPeakSlots.add({
                            'start': const TimeOfDay(hour: 22, minute: 0),
                            'end': const TimeOfDay(hour: 6, minute: 0),
                          });
                        }
                        if (!value) {
                          _offPeakSlots.clear();
                        }
                      });
                      _createOffPeakReminders();
                      _savePreferences();
                    },
                    activeColor: colorScheme.primary,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Rappels générés pour les heures creuses
        if (offPeakReminders.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 16, top: 4),
            child: Column(
              children: offPeakReminders.map((reminder) {
                final index = _reminders.indexOf(reminder);
                return _buildMiniReminderCard(reminder, index, colorScheme);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  /// Mini carte de rappel (affichée sous les configurations)
  Widget _buildMiniReminderCard(
    Reminder reminder,
    int index,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4),
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editReminder(reminder),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(reminder.type.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: reminder.isActive
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (reminder.scheduledTime != null)
                      Text(
                        '${reminder.scheduledTime!.hour.toString().padLeft(2, '0')}:${reminder.scheduledTime!.minute.toString().padLeft(2, '0')} • ${reminder.frequency.displayName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: reminder.isActive,
                onChanged: (_) => _toggleReminder(index),
                activeColor: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog centré pour configurer les heures creuses
  void _showOffPeakConfigDialog() {
    ReminderFrequency selectedFrequency = ReminderFrequency.daily;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Text('⏰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    'Configurer les heures creuses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plages horaires
                    Text(
                      'Vos plages d\'heures creuses',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._offPeakSlots.asMap().entries.map((entry) {
                      final index = entry.key;
                      final slot = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              'Plage ${index + 1}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTimeButton(
                              time: slot['start']!,
                              label: 'Début',
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: slot['start']!,
                                );
                                if (time != null) {
                                  setState(
                                    () => _offPeakSlots[index]['start'] = time,
                                  );
                                  setDialogState(() {});
                                  _createOffPeakReminders();
                                  _savePreferences();
                                }
                              },
                              colorScheme: colorScheme,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.arrow_forward, size: 14),
                            ),
                            _buildTimeButton(
                              time: slot['end']!,
                              label: 'Fin',
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: slot['end']!,
                                );
                                if (time != null) {
                                  setState(
                                    () => _offPeakSlots[index]['end'] = time,
                                  );
                                  setDialogState(() {});
                                  _createOffPeakReminders();
                                  _savePreferences();
                                }
                              },
                              colorScheme: colorScheme,
                            ),
                            if (_offPeakSlots.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: colorScheme.error,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() => _offPeakSlots.removeAt(index));
                                  setDialogState(() {});
                                  _createOffPeakReminders();
                                  _savePreferences();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      );
                    }),

                    if (_offPeakSlots.length < 2)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _offPeakSlots.add({
                              'start': const TimeOfDay(hour: 12, minute: 0),
                              'end': const TimeOfDay(hour: 14, minute: 0),
                            });
                          });
                          setDialogState(() {});
                          _createOffPeakReminders();
                          _savePreferences();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ajouter une 2ème plage'),
                      ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Fréquence des rappels
                    Text(
                      'Fréquence des rappels',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildFrequencyOption(
                      'Quotidien',
                      'Sélectionnez les jours actifs',
                      Icons.today,
                      _offPeakFrequency == ReminderFrequency.daily,
                      () {
                        setState(
                          () => _offPeakFrequency = ReminderFrequency.daily,
                        );
                        setDialogState(() {});
                        _savePreferences();
                        _createOffPeakReminders();
                      },
                      colorScheme,
                    ),

                    // Sélection des jours pour quotidien
                    if (_offPeakFrequency == ReminderFrequency.daily) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Wrap(
                          spacing: 6,
                          children: [
                            _buildDayChip('L', 1, setDialogState, colorScheme),
                            _buildDayChip('M', 2, setDialogState, colorScheme),
                            _buildDayChip('M', 3, setDialogState, colorScheme),
                            _buildDayChip('J', 4, setDialogState, colorScheme),
                            _buildDayChip('V', 5, setDialogState, colorScheme),
                            _buildDayChip('S', 6, setDialogState, colorScheme),
                            _buildDayChip('D', 7, setDialogState, colorScheme),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    _buildFrequencyOption(
                      'Hebdomadaire',
                      'Choisissez le jour de rappel',
                      Icons.date_range,
                      _offPeakFrequency == ReminderFrequency.weekly,
                      () {
                        setState(
                          () => _offPeakFrequency = ReminderFrequency.weekly,
                        );
                        setDialogState(() {});
                        _savePreferences();
                        _createOffPeakReminders();
                      },
                      colorScheme,
                    ),

                    // Sélection du jour pour hebdomadaire
                    if (_offPeakFrequency == ReminderFrequency.weekly) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Wrap(
                          spacing: 6,
                          children: [
                            _buildWeekdayChip(
                              'Lundi',
                              1,
                              setDialogState,
                              colorScheme,
                            ),
                            _buildWeekdayChip(
                              'Mardi',
                              2,
                              setDialogState,
                              colorScheme,
                            ),
                            _buildWeekdayChip(
                              'Mercredi',
                              3,
                              setDialogState,
                              colorScheme,
                            ),
                            _buildWeekdayChip(
                              'Jeudi',
                              4,
                              setDialogState,
                              colorScheme,
                            ),
                            _buildWeekdayChip(
                              'Vendredi',
                              5,
                              setDialogState,
                              colorScheme,
                            ),
                            _buildWeekdayChip(
                              'Samedi',
                              6,
                              setDialogState,
                              colorScheme,
                            ),
                            _buildWeekdayChip(
                              'Dimanche',
                              7,
                              setDialogState,
                              colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    _createOffPeakReminders();
                    _savePreferences();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Heures creuses configurées !'),
                      ),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Widget pour les options de fréquence
  Widget _buildFrequencyOption(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// Chip pour sélection des jours actifs (quotidien)
  Widget _buildDayChip(
    String label,
    int day,
    StateSetter setDialogState,
    ColorScheme colorScheme,
  ) {
    final isSelected = _offPeakDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _offPeakDays.add(day);
            _offPeakDays.sort();
          } else {
            _offPeakDays.remove(day);
          }
        });
        setDialogState(() {});
        _savePreferences();
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Chip pour sélection du jour de la semaine (hebdomadaire)
  Widget _buildWeekdayChip(
    String label,
    int day,
    StateSetter setDialogState,
    ColorScheme colorScheme,
  ) {
    final isSelected = _offPeakWeekday == day;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _offPeakWeekday = day);
          setDialogState(() {});
          _savePreferences();
        }
      },
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Bouton pour sélectionner une heure
  Widget _buildTimeButton({
    required TimeOfDay time,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// Sélectionner une heure pour une plage
  Future<void> _selectTime(int slotIndex, String field) async {
    final currentTime = _offPeakSlots[slotIndex][field]!;
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (time != null) {
      setState(() {
        _offPeakSlots[slotIndex][field] = time;
      });
      _createOffPeakReminders();
      _savePreferences();
    }
  }

  /// Carte spéciale pour Météo & Localisation avec switch on/off
  Widget _buildWeatherLocationCard(
    _SuggestedAction action,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _weatherLocationEnabled
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.primaryContainer,
                        _weatherLocationEnabled
                            ? colorScheme.secondary.withOpacity(0.3)
                            : colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      action.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _weatherLocationEnabled
                            ? 'Accès autorisé'
                            : action.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: _weatherLocationEnabled
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _weatherLocationEnabled,
                  onChanged: (value) {
                    setState(() => _weatherLocationEnabled = value);
                    _updateWeatherReminder();
                    _savePreferences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Vous recevrez des conseils basés sur la météo'
                              : 'Conseils météo désactivés',
                        ),
                      ),
                    );
                  },
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
          ),
          // Message quand activé
          if (_weatherLocationEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vous recevrez des rappels et conseils liés à votre météo locale',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Carte spéciale pour Alerte Consommation avec switch on/off
  Widget _buildConsumptionCard(
    _SuggestedAction action,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _consumptionAlertEnabled
                            ? Colors.orange.withOpacity(0.3)
                            : colorScheme.primaryContainer,
                        _consumptionAlertEnabled
                            ? Colors.red.withOpacity(0.3)
                            : colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      action.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _consumptionAlertEnabled
                            ? 'Alertes activées'
                            : action.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: _consumptionAlertEnabled
                              ? Colors.orange
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _consumptionAlertEnabled,
                  onChanged: (value) {
                    setState(() => _consumptionAlertEnabled = value);
                    _updateConsumptionReminder(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Vous serez alerté en cas de consommation anormale'
                              : 'Alertes de consommation désactivées',
                        ),
                      ),
                    );
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
          // Message quand activé
          if (_consumptionAlertEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vous serez alerté si votre consommation dépasse la normale',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Carte spéciale pour Équipements avec navigation
  Widget _buildEquipmentCard(_SuggestedAction action, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers la page d'inventaire
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Navigation vers l\'inventaire (à venir)'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    action.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Carte pour choisir le type de chauffage (collectif/individuel)
  Widget _buildHeatingTypeCard(
    _SuggestedAction action,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      action.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Collectif',
                    icon: Icons.apartment,
                    isSelected: _heatingType == 'collectif',
                    onTap: () {
                      setState(
                        () => _heatingType = _heatingType == 'collectif'
                            ? null
                            : 'collectif',
                      );
                      _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Individuel',
                    icon: Icons.home,
                    isSelected: _heatingType == 'individuel',
                    onTap: () {
                      setState(
                        () => _heatingType = _heatingType == 'individuel'
                            ? null
                            : 'individuel',
                      );
                      _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Carte pour choisir l'énergie de chauffage (gaz/électrique)
  Widget _buildHeatingEnergyCard(
    _SuggestedAction action,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      action.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Gaz',
                    icon: Icons.local_fire_department,
                    isSelected: _heatingEnergy == 'gaz',
                    onTap: () {
                      setState(
                        () => _heatingEnergy = _heatingEnergy == 'gaz'
                            ? null
                            : 'gaz',
                      );
                      _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Électrique',
                    icon: Icons.bolt,
                    isSelected: _heatingEnergy == 'electrique',
                    onTap: () {
                      setState(
                        () => _heatingEnergy = _heatingEnergy == 'electrique'
                            ? null
                            : 'electrique',
                      );
                      _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget bouton de choix réutilisable
  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfigDialog({
    _SuggestedAction? suggestion,
    Reminder? existing,
  }) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) =>
          _ReminderConfigDialog(suggestion: suggestion, existing: existing),
    );
    if (result != null) {
      setState(() {
        if (existing != null) {
          final index = _reminders.indexWhere((r) => r.id == existing.id);
          if (index != -1) _reminders[index] = result;
        } else {
          _reminders.add(result.copyWith(id: _nextId++));
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existing != null
                  ? 'Rappel modifié'
                  : 'Rappel "${result.title}" créé',
            ),
          ),
        );
      }
    }
  }

  void _createFromSuggestion(_SuggestedAction action) =>
      _showConfigDialog(suggestion: action);
  void _editReminder(Reminder reminder) =>
      _showConfigDialog(existing: reminder);
  void _toggleReminder(int index) => setState(() {
    final r = _reminders[index];
    _reminders[index] = r.copyWith(isActive: !r.isActive);
  });

  void _deleteReminder(int index) {
    final reminder = _reminders[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rappel ?'),
        content: Text('Voulez-vous vraiment supprimer "${reminder.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _reminders.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Rappel supprimé'),
                  action: SnackBarAction(
                    label: 'Annuler',
                    onPressed: () =>
                        setState(() => _reminders.insert(index, reminder)),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ============ CLASSES INTERNES ============

class _SuggestedAction {
  final String id, title, description, icon;
  final ReminderType type;
  final bool isPopular;
  const _SuggestedAction({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    this.isPopular = false,
  });
}

class _ReminderConfigDialog extends StatefulWidget {
  final _SuggestedAction? suggestion;
  final Reminder? existing;
  const _ReminderConfigDialog({this.suggestion, this.existing});
  @override
  State<_ReminderConfigDialog> createState() => _ReminderConfigDialogState();
}

class _ReminderConfigDialogState extends State<_ReminderConfigDialog> {
  late TextEditingController _titleController,
      _descriptionController,
      _thresholdController;
  late ReminderType _selectedType;
  late ReminderFrequency _selectedFrequency;
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  final _dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final r = widget.existing!;
      _titleController = TextEditingController(text: r.title);
      _descriptionController = TextEditingController(text: r.description);
      _thresholdController = TextEditingController(
        text: r.threshold?.toString() ?? '',
      );
      _selectedType = r.type;
      _selectedFrequency = r.frequency;
      _selectedTime = r.scheduledTime != null
          ? TimeOfDay.fromDateTime(r.scheduledTime!)
          : const TimeOfDay(hour: 8, minute: 0);
      _selectedDays = List.from(r.activeDays);
    } else if (widget.suggestion != null) {
      final s = widget.suggestion!;
      _titleController = TextEditingController(text: s.title);
      _descriptionController = TextEditingController(text: s.description);
      _thresholdController = TextEditingController();
      _selectedType = s.type;
      _selectedFrequency = _selectedType.requiresThreshold
          ? ReminderFrequency.realtime
          : ReminderFrequency.daily;
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
      _selectedDays = [1, 2, 3, 4, 5, 6, 7];
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _thresholdController = TextEditingController();
      _selectedType = ReminderType.offPeakHours;
      _selectedFrequency = ReminderFrequency.daily;
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
      _selectedDays = [1, 2, 3, 4, 5, 6, 7];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.existing != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _selectedType.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isEditing ? 'Modifier le rappel' : 'Nouveau rappel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre du rappel',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Heure du rappel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (t != null) setState(() => _selectedTime = t);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedType.requiresThreshold) ...[
                      Text(
                        'Seuil d\'alerte',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              _selectedType == ReminderType.highConsumption
                              ? 'Pourcentage'
                              : 'Température',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.thermostat),
                          suffixText:
                              _selectedType == ReminderType.highConsumption
                              ? '%'
                              : '°C',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: Icon(isEditing ? Icons.check : Icons.add),
                      label: Text(isEditing ? 'Enregistrer' : 'Créer'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez entrer un titre')));
      return;
    }
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    Navigator.pop(
      context,
      Reminder(
        id: widget.existing?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        frequency: _selectedFrequency,
        scheduledTime: _selectedFrequency != ReminderFrequency.realtime
            ? scheduledTime
            : null,
        activeDays: _selectedDays,
        isActive: true,
        threshold: double.tryParse(_thresholdController.text),
        thresholdUnit: _selectedType.requiresThreshold
            ? (_selectedType == ReminderType.highConsumption ? '%' : '°C')
            : null,
      ),
    );
  }

  Widget _buildFrequencyChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayButton(String label, int day, ColorScheme colorScheme) {
    final isSelected = _selectedDays.length == 1 && _selectedDays.first == day;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDays.clear();
            _selectedDays.add(day);
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
