import 'db-creator.dart';

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