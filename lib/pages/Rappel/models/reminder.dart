// Modèles pour la gestion des rappels

/// Modèle représentant un rappel programmé
class Reminder {
  final int? id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderFrequency frequency;
  final DateTime? scheduledTime;
  final List<int> activeDays;
  final bool isActive;
  final double? threshold;
  final String? thresholdUnit;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    this.scheduledTime,
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7],
    this.isActive = true,
    this.threshold,
    this.thresholdUnit,
  });

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    DateTime? scheduledTime,
    List<int>? activeDays,
    bool? isActive,
    double? threshold,
    String? thresholdUnit,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      activeDays: activeDays ?? this.activeDays,
      isActive: isActive ?? this.isActive,
      threshold: threshold ?? this.threshold,
      thresholdUnit: thresholdUnit ?? this.thresholdUnit,
    );
  }

  /// Convertir en JSON pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'frequency': frequency.index,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'activeDays': activeDays,
      'isActive': isActive,
      'threshold': threshold,
      'thresholdUnit': thresholdUnit,
    };
  }

  /// Créer depuis JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ReminderType.values[json['type']],
      frequency: ReminderFrequency.values[json['frequency']],
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      activeDays: List<int>.from(json['activeDays']),
      isActive: json['isActive'],
      threshold: json['threshold']?.toDouble(),
      thresholdUnit: json['thresholdUnit'],
    );
  }
}

enum ReminderType {
  offPeakHours,
  peakHours,
  highConsumption,
  equipmentUsage,
  weatherLocation,
  heatingType,
  heatingEnergy,
}

extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.offPeakHours:
        return 'Heures creuses';
      case ReminderType.peakHours:
        return 'Heures pleines';
      case ReminderType.highConsumption:
        return 'Consommation élevée';
      case ReminderType.equipmentUsage:
        return 'Mes équipements';
      case ReminderType.weatherLocation:
        return 'Météo & Localisation';
      case ReminderType.heatingType:
        return 'Type de chauffage';
      case ReminderType.heatingEnergy:
        return 'Énergie de chauffage';
    }
  }

  String get icon {
    switch (this) {
      case ReminderType.offPeakHours:
        return '🌙';
      case ReminderType.peakHours:
        return '☀️';
      case ReminderType.highConsumption:
        return '⚡';
      case ReminderType.equipmentUsage:
        return '🔌';
      case ReminderType.weatherLocation:
        return '🌤️';
      case ReminderType.heatingType:
        return '🏠';
      case ReminderType.heatingEnergy:
        return '⚡';
    }
  }

  bool get requiresThreshold {
    return this == ReminderType.highConsumption;
  }

  bool get requiresPermission {
    return this == ReminderType.weatherLocation;
  }

  bool get navigatesToPage {
    return this == ReminderType.equipmentUsage;
  }

  bool get requiresChoice {
    return this == ReminderType.heatingType ||
        this == ReminderType.heatingEnergy;
  }
}

enum ReminderFrequency { once, daily, weekly, monthly, realtime }

extension ReminderFrequencyExtension on ReminderFrequency {
  String get displayName {
    switch (this) {
      case ReminderFrequency.once:
        return 'Une fois';
      case ReminderFrequency.daily:
        return 'Quotidien';
      case ReminderFrequency.weekly:
        return 'Hebdomadaire';
      case ReminderFrequency.monthly:
        return 'Mensuel';
      case ReminderFrequency.realtime:
        return 'Temps réel';
    }
  }
}
