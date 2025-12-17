import 'package:sqflite/sqflite.dart';
import '../../../shared/local_database/db-creator.dart';
import '../models/content_model.dart';

/// Service pour gérer les opérations CRUD sur la table Content
class ContentService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insère un nouveau contenu dans la base de données
  Future<int> insertContent(ContentModel content) async {
    final db = await _dbHelper.database;
    return await db.insert('Content', content.toMap());
  }

  /// Insère plusieurs contenus en une seule transaction
  Future<void> insertMultipleContents(List<ContentModel> contents) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var content in contents) {
      batch.insert('Content', content.toMap());
    }

    await batch.commit(noResult: true);
  }

  /// Récupère tous les contenus
  Future<List<ContentModel>> getAllContents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Content');

    return List.generate(maps.length, (i) {
      return ContentModel.fromMap(maps[i]);
    });
  }

  /// Récupère les contenus par type (article, fiche, tutorial)
  Future<List<ContentModel>> getContentsByType(String type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'type = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return ContentModel.fromMap(maps[i]);
    });
  }

  /// Récupère les contenus favoris
  Future<List<ContentModel>> getFavoriteContents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return ContentModel.fromMap(maps[i]);
    });
  }

  /// Recherche des contenus par titre ou tags
  Future<List<ContentModel>> searchContents(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'title LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return ContentModel.fromMap(maps[i]);
    });
  }

  /// Met à jour un contenu
  Future<int> updateContent(ContentModel content) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Content',
      content.toMap(),
      where: 'id = ?',
      whereArgs: [content.id],
    );
  }

  /// Marque un contenu comme lu
  Future<int> markAsRead(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Content',
      {'hasBeenRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle favori
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Content',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Met à jour la notation
  Future<int> updateNotation(int id, int notation) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Content',
      {'notation': notation},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime un contenu
  Future<int> deleteContent(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'Content',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime tous les contenus
  Future<int> deleteAllContents() async {
    final db = await _dbHelper.database;
    return await db.delete('Content');
  }

  /// Récupère l'article à la une
  Future<ContentModel?> getFeaturedContent() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'isFeatured = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ContentModel.fromMap(maps[0]);
  }

  /// Recherche par catégorie
  Future<List<ContentModel>> getContentsByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'category = ?',
      whereArgs: [category],
    );

    return List.generate(maps.length, (i) {
      return ContentModel.fromMap(maps[i]);
    });
  }

  /// Recherche par tag
  Future<List<ContentModel>> getContentsByTag(String tag) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
    );

    return List.generate(maps.length, (i) {
      return ContentModel.fromMap(maps[i]);
    });
  }

  /// Récupère tous les tags uniques
  Future<List<String>> getAllTags() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Content');

    final Set<String> tagsSet = {};
    for (var map in maps) {
      final tags = (map['tags'] as String).split(',');
      for (var tag in tags) {
        tagsSet.add(tag.trim());
      }
    }

    return tagsSet.toList()..sort();
  }

  /// Réinitialise complètement la base de données
  Future<void> resetDatabase() async {
    await _dbHelper.resetDatabase();
  }
}
