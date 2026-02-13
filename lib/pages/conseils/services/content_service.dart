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

  /// Récupère l'article à la une pour un type donné (ex: 'fiche' ou 'tutorial').
  Future<ContentModel?> getFeaturedContentByType(String type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      where: 'isFeatured = ? AND type = ?',
      whereArgs: [1, type],
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

  /// Récupère tous les tags uniques uniquement pour un type de contenu.
  ///
  /// Exemple: type='fiche' => uniquement les tags présents dans les fiches.
  Future<List<String>> getAllTagsByType(String type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Content',
      columns: const ['tags'],
      where: 'type = ?',
      whereArgs: [type],
    );

    final Set<String> tagsSet = {};
    for (final map in maps) {
      final raw = (map['tags'] as String?) ?? '';
      if (raw.trim().isEmpty) continue;
      for (final tag in raw.split(',')) {
        final t = tag.trim();
        if (t.isNotEmpty) tagsSet.add(t);
      }
    }

    return tagsSet.toList()..sort();
  }

  /// Réinitialise complètement la base de données
  Future<void> resetDatabase() async {
    await _dbHelper.resetDatabase();
  }

  /// Upsert d'un contenu à partir de son identifiant distant (Firestore).
  ///
  /// - Si `remoteId` est null/empty, on fallback sur un insert classique.
  /// - Si un contenu existe déjà, on conserve ses champs "locaux"
  ///   (hasBeenRead/isFavorite/notation) et on met à jour les champs "distants"
  ///   (title/tags/type/category/readingTime/isFeatured/pdfUrl).
  Future<int> upsertByRemoteId(ContentModel content) async {
    final db = await _dbHelper.database;

    final remoteId = content.remoteId;
    if (remoteId == null || remoteId.isEmpty) {
      return insertContent(content);
    }

    final existing = await db.query(
      'Content',
      where: 'remoteId = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (existing.isEmpty) {
      return await db.insert('Content', content.toMap());
    }

    final existingRow = existing.first;

    // Préserver l'état local
    final preservedHasBeenRead = (existingRow['hasBeenRead'] ?? 0) == 1;
    final preservedIsFavorite = (existingRow['isFavorite'] ?? 0) == 1;
    final preservedNotation = (existingRow['notation'] as int?) ?? 0;

    final updated = content.copyWith(
      id: existingRow['id'] as int?,
      hasBeenRead: preservedHasBeenRead,
      isFavorite: preservedIsFavorite,
      notation: preservedNotation,
    );

    return await db.update(
      'Content',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  /// Définit explicitement le favori (true/false)
  Future<int> setFavorite(int id, bool isFavorite) async {
    return toggleFavorite(id, isFavorite);
  }

  /// Met à jour le temps de lecture (en minutes)
  Future<int> updateReadingTime(int id, int readingTime) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Content',
      {'readingTime': readingTime},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Inverse l'état favori en base pour un contenu.
  ///
  /// Retourne la nouvelle valeur (true si favori après l'opération).
  ///
  /// Note: on lit l'état actuel en DB (source de vérité) pour éviter les désync UI.
  Future<bool> toggleFavoriteById(int id) async {
    final db = await _dbHelper.database;

    final rows = await db.query(
      'Content',
      columns: ['isFavorite'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    final current = rows.isNotEmpty && (rows.first['isFavorite'] ?? 0) == 1;
    final next = !current;

    await db.update(
      'Content',
      {'isFavorite': next ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    return next;
  }
}
