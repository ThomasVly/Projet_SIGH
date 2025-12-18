/// Modèle pour les contenus (Articles, Fiches info, Tutoriels)
class ContentModel {
  final int? id;
  final String title;
  final String tags;
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
    required this.title,
    required this.tags,
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
      'title': title,
      'tags': tags,
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

  /// Crée un objet ContentModel depuis une Map SQLite
  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      tags: map['tags'] as String,
      hasBeenRead: map['hasBeenRead'] == 1,
      notation: map['notation'] as int,
      isFavorite: map['isFavorite'] == 1,
      type: map['type'] as String,
      category: (map['category'] as String?) ?? 'Électricité', // Valeur par défaut si null
      readingTime: (map['readingTime'] as int?) ?? 5, // Valeur par défaut si null
      isFeatured: (map['isFeatured'] ?? 0) == 1,
      pdfUrl: (map['pdfUrl'] as String?) ?? '',
    );
  }

  /// Retourne la liste des tags sous forme de liste
  List<String> getTagsList() {
    return tags.split(',').map((tag) => tag.trim()).toList();
  }

  /// Retourne l'icône correspondant à la catégorie
  String getCategoryIcon() {
    switch (category.toLowerCase()) {
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
    String? title,
    String? tags,
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
      title: title ?? this.title,
      tags: tags ?? this.tags,
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
