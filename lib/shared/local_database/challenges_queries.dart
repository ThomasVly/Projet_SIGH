import 'package:sqflite/sqflite.dart';
import 'db-creator.dart';

/// Récupérer le statut d'un défi par son id
Future<Map<String, dynamic>?> getChallengeStatus(String id) async {
  final db = await DatabaseHelper.instance.database;
  final result = await db.query(
    'Challenges',
    where: 'id = ?',
    whereArgs: [id],
  );
  return result.isNotEmpty ? result.first : null;
}

/// Récupérer tous les statuts de défis
Future<List<Map<String, dynamic>>> getAllChallengeStatuses() async {
  final db = await DatabaseHelper.instance.database;
  return await db.query('Challenges');
}

/// Insérer / mettre à jour le statut d'un défi
Future<void> upsertChallengeStatus({
  required String id,
  required bool completed,
  required int reward,
}) async {
  final db = await DatabaseHelper.instance.database;

  await db.insert(
    'Challenges',
    {
      'id': id,
      'completed': completed ? 1 : 0, // sqflite attend int pour bool
      'reward': reward,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
