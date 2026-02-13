// lib/pages/defis/models/challenge_models.dart

class ChallengeDefinition {
  final String id;
  final String title;
  final String description;
  final String reminder;
  final int reward;

  /// Mois au format "YYYY-MM" (ex: "2024-12")
  final String month;

  /// Vrai si ce défi correspond au mois en cours
  final bool isCurrent;

  ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.reminder,
    required this.reward,
    required this.month,
    required this.isCurrent,
  });

  /// Création à partir des données Firestore (Map + id du document)
  factory ChallengeDefinition.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final monthString = data['month'] as String? ?? '';

    return ChallengeDefinition(
      id: id,
      title: data['title'] as String? ?? 'Défi sans titre',
      description: data['description'] as String? ?? '',
      reminder: data['reminder'] as String? ?? '',
      reward: (data['reward'] as int?) ?? 0,
      month: monthString,
      isCurrent: _isCurrentMonth(monthString),
    );
  }

  /// Compare le champ "YYYY-MM" avec le mois actuel
  static bool _isCurrentMonth(String monthString) {
    if (monthString.isEmpty) return false;

    final now = DateTime.now();
    final current = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    return monthString == current;
  }

  /// Vrai si le défi est dans un mois déjà passé
  bool get isPast {
    if (month.isEmpty) return false;
    final now = DateTime.now();
    final current = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    return month.compareTo(current) < 0;
  }

  /// Vrai si le défi est dans un mois futur
  bool get isFuture {
    if (month.isEmpty) return false;
    final now = DateTime.now();
    final current = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    return month.compareTo(current) > 0;
  }

  /// Label affichable : "Décembre 2024"
  String get monthLabel {
    final parts = month.split('-'); // ["2024", "12"]
    if (parts.length != 2) return month;

    final int monthNum = int.tryParse(parts[1]) ?? 1;
    final List<String> months = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre"
    ];

    final monthName = months[(monthNum - 1).clamp(0, 11)];
    return "$monthName ${parts[0]}";
  }
}

class ChallengeStatus {
  final String id;
  final bool completed;
  final int reward;

  ChallengeStatus({
    required this.id,
    required this.completed,
    required this.reward,
  });

  factory ChallengeStatus.fromDb(Map<String, dynamic> row) {
    return ChallengeStatus(
      id: row['id'] as String,
      completed: (row['completed'] as int) == 1,
      reward: row['reward'] as int,
    );
  }
}

class ChallengeWithStatus {
  final ChallengeDefinition definition;
  final ChallengeStatus status;

  ChallengeWithStatus({
    required this.definition,
    required this.status,
  });

  ChallengeWithStatus copyWith({
    ChallengeDefinition? definition,
    ChallengeStatus? status,
  }) {
    return ChallengeWithStatus(
      definition: definition ?? this.definition,
      status: status ?? this.status,
    );
  }
}
