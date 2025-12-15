import 'db-creator.dart';

/// Récupère tous les utilisateurs de la base de données
Future<List<Map<String, dynamic>>> getAllUsers() async {
  final db = await DatabaseHelper.instance.database;
  return await db.query('Users', orderBy: 'id DESC');
}

/// Récupère un utilisateur par son ID
Future<Map<String, dynamic>?> getUserById(int id) async {
  final db = await DatabaseHelper.instance.database;
  final result = await db.query(
    'Users',
    where: 'id = ?',
    whereArgs: [id],
  );
  return result.isNotEmpty ? result.first : null;
}

/// Récupère un utilisateur par son nom
Future<Map<String, dynamic>?> getUserByUsername(String username) async {
  final db = await DatabaseHelper.instance.database;
  final result = await db.query(
    'Users',
    where: 'username = ?',
    whereArgs: [username],
  );
  return result.isNotEmpty ? result.first : null;
}

/// EXAMPLE FOR WHERE QUERIES (CONTENT NOT RELATED TO CURRENT PROJECT)
/// Récupère le nombre total de villes dans la base
Future<int> getLocationCount({bool onlyCapitals = false}) async {
  final db = await DatabaseHelper.instance.database;

  String whereClause = '';
  if (onlyCapitals) {
    whereClause = "WHERE capital = 'primary' OR capital = 'admin' OR capital = 'minor'";
  }

  final result = await db.rawQuery('SELECT COUNT(*) as count FROM Locations $whereClause');
  return result.first['count'] as int;
}