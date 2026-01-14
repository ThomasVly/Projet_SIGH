import '../../../shared/firebase/firestore_service.dart';
import '../models/content_model.dart';
import 'content_service.dart';

/// Synchronise les contenus depuis Firestore vers la base locale SQLite.
///
/// Source de vérité: Firestore.
/// Cache/offline: SQLite (table Content).
///
/// Politique:
/// - on upsert via `remoteId` (id Firestore)
/// - on conserve les champs "locaux" (hasBeenRead/isFavorite/notation) si déjà présents
/// - on ne supprime pas (pour l'instant) les contenus locaux qui ne sont plus sur Firestore
class ContentSyncService {
  final ContentService _contentService;

  ContentSyncService({ContentService? contentService})
      : _contentService = contentService ?? ContentService();

  /// Récupère Firestore, mappe vers ContentModel, puis upsert en base locale.
  ///
  /// Retourne le nombre de contenus traités.
  Future<int> syncFromFirestore() async {
    final remoteDocs = await FirestoreService.getConseils();
    if (remoteDocs.isEmpty) return 0;

    int count = 0;
    for (final doc in remoteDocs) {
      final content = _mapFirestoreDocToContent(doc);
      if (content == null) continue;

      await _contentService.upsertByRemoteId(content);
      count++;
    }

    return count;
  }

  /// Convertit un document Firestore (Map) en ContentModel.
  ///
  /// Champs réellement attendus côté Firestore (selon ton schéma actuel):
  /// - id (docId)
  /// - title (String)
  /// - description (String)  -> utilisé pour déduire category (ex: "chauffage")
  /// - detail (String)       -> lien (PDF ou autre)
  /// - pdf (bool)            -> indique si c'est un PDF (pour l'instant on considère que oui)
  /// - tags (List<String>)
  /// - type (String)         -> côté app on attend 'fiche' | 'tutorial'
  /// - timestamp (Timestamp)
  ///
  /// Le reste est complété localement (SQLite):
  /// - category, readingTime, isFeatured, pdfUrl, hasBeenRead, isFavorite, notation
  ContentModel? _mapFirestoreDocToContent(Map<String, dynamic> doc) {
    final remoteId = doc['id']?.toString();
    final title = doc['title']?.toString().trim();

    // Dans ton schéma Firestore, `type` existe bien.
    // On normalise juste pour coller aux valeurs attendues côté app.
    final type = _normalizeType(doc['type']?.toString());

    // `detail` contient le lien. On le stocke dans pdfUrl pour l'affichage.
    final detail = doc['detail']?.toString().trim();

    if (remoteId == null || remoteId.isEmpty) return null;
    if (title == null || title.isEmpty) return null;
    if (type == null || type.isEmpty) return null;
    if (detail == null || detail.isEmpty) return null;

    // tags: dans Firestore tu as une liste, on la stocke en CSV côté SQLite.
    final tags = _normalizeTags(doc['tags']);

    // category: on la déduit de description si possible, sinon fallback.
    final description = doc['description']?.toString().trim();
    final category = _deriveCategory(description, tags, title);

    // readingTime: pas présent dans Firestore -> heuristique simple.
    final readingTime = _estimateReadingTimeMinutes(description);

    // isFeatured: pas présent dans Firestore -> on peut le déduire si tag "Urgent" / "A la une".
    final isFeatured = _deriveIsFeatured(tags, title);

    // hasBeenRead / isFavorite / notation : champs 100% locaux pour le moment.
    const hasBeenRead = false;
    const isFavorite = false;
    const notation = 0;

    // pdfUrl: si pdf==true on l'utilise comme lien PDF.
    // Si pdf est absent, on accepte quand même (on traite detail comme lien PDF).
    final isPdf = _asBool(doc['pdf']) ?? true;
    final pdfUrl = isPdf ? detail : detail;

    return ContentModel(
      remoteId: remoteId,
      title: title,
      tags: tags,
      type: type,
      category: category,
      readingTime: readingTime,
      isFeatured: isFeatured,
      hasBeenRead: hasBeenRead,
      isFavorite: isFavorite,
      notation: notation,
      pdfUrl: pdfUrl,
    );
  }

  String? _normalizeType(String? raw) {
    if (raw == null) return null;
    final v = raw.trim().toLowerCase();

    // Valeurs déjà OK
    if (v == 'fiche') return 'fiche';
    if (v == 'tutorial') return 'tutorial';

    // Petits alias possibles
    if (v == 'tutoriel') return 'tutorial';
    if (v == 'tuto') return 'tutorial';

    // Si Firestore envoie d'autres types, on les ignore plutôt que d'insérer des données incohérentes.
    return null;
  }

  String _deriveCategory(String? description, String tagsCsv, String title) {
    final source = '${description ?? ''},$tagsCsv,$title'.toLowerCase();

    if (source.contains('chauffage') || source.contains('radiateur')) return 'Chauffage';
    if (source.contains('lavage') || source.contains('lave')) return 'Lavage';
    if (source.contains('electrom') || source.contains('électrom')) return 'Électroménager';
    if (source.contains('électric') || source.contains('electric') || source.contains('éclairage')) {
      return 'Électricité';
    }

    return 'Électricité';
  }

  int _estimateReadingTimeMinutes(String? description) {
    // Heuristique simple: on n'a pas le nombre de pages.
    // On se base sur la longueur de description si présente.
    final text = (description ?? '').trim();
    if (text.isEmpty) return 5;

    // ~200 mots/min, approximé par ~5 caractères/mot.
    final approxWords = (text.length / 5).round();
    final minutes = (approxWords / 200).ceil();
    return minutes.clamp(1, 15);
  }

  bool _deriveIsFeatured(String tagsCsv, String title) {
    final s = '$tagsCsv,$title'.toLowerCase();
    return s.contains('urgent') || s.contains('à la une') || s.contains('a la une');
  }

  String _normalizeTags(dynamic raw) {
    if (raw == null) return '';

    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join(',');
    }

    // Firestore peut envoyer une String "a,b,c"
    return raw.toString();
  }

  bool? _asBool(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is int) return raw == 1;
    final s = raw.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }
}
