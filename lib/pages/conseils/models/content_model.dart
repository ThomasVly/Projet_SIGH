/// Modèle pour les contenus (Articles, Fiches info, Tutoriels)
class ContentModel {
  final int? id;
  final String? remoteId;
  final String title;
  final String tags;
  final String description;
  final bool hasBeenRead;
  final int notation;
  final bool isFavorite;
  final String type; // 'article', 'fiche', 'tutorial'
  final String category; // 'Chauffage', 'Électricité', 'Lavage', 'Électroménager'
  final int readingTime; // Temps de lecture en minutes
  final bool isFeatured; // Article à la une
  final String pdfUrl; // URL ou chemin du fichier PDF

  ContentModel({
    this.id,
    this.remoteId,
    required this.title,
    required this.tags,
    this.description = '',
    this.hasBeenRead = false,
    this.notation = 0,
    this.isFavorite = false,
    required this.type,
    required this.category,
    required this.readingTime,
    this.isFeatured = false,
    required this.pdfUrl,
  });

  /// Convertit un objet ContentModel en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remoteId': remoteId,
      'title': title,
      'tags': tags,
      'description': description,
      'hasBeenRead': hasBeenRead ? 1 : 0,
      'notation': notation,
      'isFavorite': isFavorite ? 1 : 0,
      'type': type,
      'category': category,
      'readingTime': readingTime,
      'isFeatured': isFeatured ? 1 : 0,
      'pdfUrl': pdfUrl,
    };
  }

  /// Retourne la liste des tags sous forme de liste
  List<String> getTagsList() {
    return _splitTags(tags);
  }

  static List<String> _splitTags(String rawTags) {
    if (rawTags.trim().isEmpty) return const [];
    return rawTags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
  }

  static String? _firstTagOrNull(String rawTags) {
    final list = _splitTags(rawTags);
    return list.isEmpty ? null : list.first;
  }

  static String _inferCategoryFromTagsOrDefault({
    required String rawTags,
    required String defaultCategory,
  }) {
    final firstTag = _firstTagOrNull(rawTags);
    // On garde la valeur du tag telle quelle (accents compris) pour l'affichage.
    return (firstTag == null || firstTag.trim().isEmpty)
        ? defaultCategory
        : firstTag;
  }

  /// Crée un objet ContentModel depuis une Map SQLite
  factory ContentModel.fromMap(Map<String, dynamic> map) {
    final tags = map['tags'] as String;

    final rawCategory = (map['category'] as String?);
    final category = (rawCategory == null || rawCategory.trim().isEmpty)
        ? _inferCategoryFromTagsOrDefault(
            rawTags: tags,
            defaultCategory: 'Électricité',
          )
        : rawCategory;

    return ContentModel(
      id: map['id'] as int?,
      remoteId: map['remoteId'] as String?,
      title: map['title'] as String,
      tags: tags,
      description: (map['description'] as String?) ?? '',
      hasBeenRead: map['hasBeenRead'] == 1,
      notation: map['notation'] as int,
      isFavorite: map['isFavorite'] == 1,
      type: map['type'] as String,
      category: category,
      readingTime: (map['readingTime'] as int?) ?? 5,
      isFeatured: (map['isFeatured'] ?? 0) == 1,
      pdfUrl: (map['pdfUrl'] as String?) ?? '',
    );
  }

  /// Retourne l'icône correspondant à la catégorie
  String getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'ademe':
        return '🏛️';
      case 'economie':
      case 'économie':
        return '💰';
      case 'chauffage':
        return '🔥';
      case 'électricité':
      case 'electricité':
      case 'électricite':
      case 'electricite':
        return '💡';
      case 'lavage':
        return '🧺';
      case 'électroménager':
      case 'electromenager':
      case 'electroménager':
      case 'électromenager':
        return '🏠';
      default:
        return '📌';
    }
  }

  /// Copie l'objet avec des modifications
  ContentModel copyWith({
    int? id,
    String? remoteId,
    String? title,
    String? tags,
    String? description,
    bool? hasBeenRead,
    int? notation,
    bool? isFavorite,
    String? type,
    String? category,
    int? readingTime,
    bool? isFeatured,
    String? pdfUrl,
  }) {
    return ContentModel(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      hasBeenRead: hasBeenRead ?? this.hasBeenRead,
      notation: notation ?? this.notation,
      isFavorite: isFavorite ?? this.isFavorite,
      type: type ?? this.type,
      category: category ?? this.category,
      readingTime: readingTime ?? this.readingTime,
      isFeatured: isFeatured ?? this.isFeatured,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}
