class UserProfile {
  final String id;
  final String userName;
  final String memberSince;
  final int totalTests;
  final int quizCount;
  final int badges;
  final int currentLevel;
  final int currentXP;
  final int maxXP;
  final String avatarEmoji;

  // Nouveaux champs pour le tracking des badges d'énergie
  final int challengeCount;
  final int articleCount;
  final int loginStreak;
  final double energySaved; // en kWh

  UserProfile({
    required this.id,
    required this.userName,
    required this.memberSince,
    this.totalTests = 0,
    this.quizCount = 0,
    this.badges = 0,
    this.currentLevel = 1,
    this.currentXP = 0,
    this.maxXP = 100,
    this.avatarEmoji = '⚡',
    this.challengeCount = 0,
    this.articleCount = 0,
    this.loginStreak = 0,
    this.energySaved = 0.0,
  });

  // Calculer le pourcentage de progression
  double get progressPercentage => maxXP > 0 ? currentXP / maxXP : 0;

  // Copier avec modifications
  UserProfile copyWith({
    String? id,
    String? userName,
    String? memberSince,
    int? totalTests,
    int? quizCount,
    int? badges,
    int? currentLevel,
    int? currentXP,
    int? maxXP,
    String? avatarEmoji,
    int? challengeCount,
    int? articleCount,
    int? loginStreak,
    double? energySaved,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      memberSince: memberSince ?? this.memberSince,
      totalTests: totalTests ?? this.totalTests,
      quizCount: quizCount ?? this.quizCount,
      badges: badges ?? this.badges,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXP: currentXP ?? this.currentXP,
      maxXP: maxXP ?? this.maxXP,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      challengeCount: challengeCount ?? this.challengeCount,
      articleCount: articleCount ?? this.articleCount,
      loginStreak: loginStreak ?? this.loginStreak,
      energySaved: energySaved ?? this.energySaved,
    );
  }

  // Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'memberSince': memberSince,
      'totalTests': totalTests,
      'quizCount': quizCount,
      'badges': badges,
      'currentLevel': currentLevel,
      'currentXP': currentXP,
      'maxXP': maxXP,
      'avatarEmoji': avatarEmoji,
      'challengeCount': challengeCount,
      'articleCount': articleCount,
      'loginStreak': loginStreak,
      'energySaved': energySaved,
    };
  }

  // Créer depuis Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      userName: map['userName'] as String,
      memberSince: map['memberSince'] as String,
      totalTests: map['totalTests'] as int? ?? 0,
      quizCount: map['quizCount'] as int? ?? 0,
      badges: map['badges'] as int? ?? 0,
      currentLevel: map['currentLevel'] as int? ?? 1,
      currentXP: map['currentXP'] as int? ?? 0,
      maxXP: map['maxXP'] as int? ?? 100,
      avatarEmoji: map['avatarEmoji'] as String? ?? '⚡',
      challengeCount: map['challengeCount'] as int? ?? 0,
      articleCount: map['articleCount'] as int? ?? 0,
      loginStreak: map['loginStreak'] as int? ?? 0,
      energySaved: (map['energySaved'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

