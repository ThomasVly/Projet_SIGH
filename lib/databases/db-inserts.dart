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

