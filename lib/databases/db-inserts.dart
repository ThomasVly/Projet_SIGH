import 'dart:ffi';

import 'package:sqflite/sqflite.dart';
import 'db-creator.dart';


/// Insère un nouveau utilisateur dans la base de données
Future<void> insertUser(String username, String localisation) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> userValues = {
    'username': username,
    'localisation': localisation,
    'nbPoints': 0,
  };
  await db.insert(
    'Users',
    userValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Utilisateur ajouté à la base de données: ${userValues['username']}, ${userValues['localisation']}');
}

/// Insère le matériel dans la base de données
Future<void> insertEquipments(String equipmentName, int moyConso, int moyUseTime, String energyType) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> equipmentValues = {
    'name': equipmentName,
    'moyConso' : moyConso,
    'moyUseTime': moyUseTime,
    'energyType' : energyType,
    'configured': false,
  };
  await db.insert(
    'Equipments',
    equipmentValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Matériel ajouté à la base de données: ${equipmentValues['name']}');
}

/// Insère un nouveau contenu (Article, Tutorial, Flashcard) dans la base de données
Future<void> insertContent(String title, List<String> tags, bool hasBeenRead, int notation, bool isFavorite, String type) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> contentValues = {
    'title': title,
    'tags': tags.join(','), // Convertir la liste en chaîne séparée par des virgules
    'hasBeenRead': hasBeenRead,
    'notation': notation,
    'isFavorite': isFavorite,
    'type': type,
  };
  await db.insert(
    'Articles',
    contentValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Contenu ajouté à la base de données: ${contentValues['title']}');
}

/// Insère un nouveau quiz dans la base de données
Future<void> insertQuiz(String name, bool completed, int score, int completionTime, int reward) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> quizValues = {
    'name': name,
    'completed': completed,
    'score': score,
    'completionTime': completionTime,
    'reward': reward,
  };
  await db.insert(
    'Quizzes',
    quizValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Quiz ajouté à la base de données: ${quizValues['name']}');
}

/// Insère un nouveau challenge dans la base de données
Future<void> insertChallenge(DateTime id, bool completed, int reward) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> challengeValues = {
    'id': id.toIso8601String(),
    'completed': completed,
    'reward': reward,
  };
  await db.insert(
    'Challenges',
    challengeValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Challenge ajouté à la base de données: ${challengeValues['id']}');
}

/// Insère une nouvelle facture dans la base de données
Future<void> insertBill(DateTime date, String content) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> billValues = {
    'date': date.toIso8601String(),
    'content': content,
  };
  await db.insert(
    'Bills',
    billValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Facture ajoutée à la base de données: ${billValues['date']}');
}

/// Insère une nouvelle alerte dans la base de données
Future<void> insertAlert(DateTime date, String content, String type) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> alertValues = {
    'date': date.toIso8601String(),
    'content': content,
    'type': type,
  };
  await db.insert(
    'Alerts',
    alertValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Alerte ajoutée à la base de données: ${alertValues['type']}');
}

/// Insère un nouveau rappel dans la base de données
Future<void> insertReminder(int correspondingEquipment, String content) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> reminderValues = {
    'correspondingEquipment': correspondingEquipment,
    'content': content,
  };
  await db.insert(
    'Reminders',
    reminderValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Rappel ajouté à la base de données: ${reminderValues['content']}');
}

/// Insère un nouveau badge dans la base de données
Future<void> insertBadge(String badgeTitle, String badgeDescription, String badgeIcon, DateTime badgeEarnedDate, int badgeReward) async {
  final db = await DatabaseHelper.instance.database;
  Map<String, dynamic> badgeValues = {
    'badgeTitle': badgeTitle,
    'badgeDescription': badgeDescription,
    'badgeIcon': badgeIcon,
    'badgeEarnedDate': badgeEarnedDate.toIso8601String(),
    'badgeReward': badgeReward,
  };
  await db.insert(
    'Badges',
    badgeValues,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print('Badge ajouté à la base de données: ${badgeValues['badgeTitle']}');
}
