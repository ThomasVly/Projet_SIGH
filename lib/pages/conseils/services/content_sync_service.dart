import '../../../shared/firebase/firestore_service.dart';
import '../models/content_model.dart';
import 'content_service.dart';
import '../../../shared/services/youtube_duration_service.dart';

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

  static const String _youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  /// Récupère Firestore, mappe vers ContentModel, puis upsert en base locale.
  ///
  /// Retourne le nombre de contenus traités.
  Future<int> syncFromFirestore() async {
    final remoteDocs = await FirestoreService.getConseils();
    if (remoteDocs.isEmpty) return 0;

    int count = 0;
    for (final doc in remoteDocs) {
      final content = await _mapFirestoreDocToContent(doc);
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
  Future<ContentModel?> _mapFirestoreDocToContent(Map<String, dynamic> doc) async {
    final remoteId = doc['id']?.toString();
    final title = doc['title']?.toString().trim();

    final type = _normalizeType(doc['type']?.toString());

    // `detail` contient le lien. On le stocke dans pdfUrl pour l'affichage.
    final detail = doc['detail']?.toString().trim();

    if (remoteId == null || remoteId.isEmpty) return null;
    if (title == null || title.isEmpty) return null;
    if (type == null || type.isEmpty) return null;
    if (detail == null || detail.isEmpty) return null;

    // description: on la stocke en local pour alimenter les pages de détail.
    final description = doc['description']?.toString().trim() ?? '';

    // tags: dans Firestore on a une liste, on la stocke en CSV côté SQLite.
    final tags = _normalizeTags(doc['tags']);

    // category: on la déduit de description si possible, sinon fallback.
    final category = _deriveCategory(description, tags, title);

    // readingTime: maintenant supporté côté Firestore.
    // Priorité:
    // 1) Firestore `readingTime` (source de vérité)
    // 2) durée YouTube (si lien YouTube)
    // 3) estimation locale
    final readingTimeFromFirestore = _asInt(doc['readingTime']);
    var readingTime =
        (readingTimeFromFirestore ?? _estimateReadingTimeMinutes(description))
            .clamp(1, 240);

    // Si c'est un lien YouTube, on tente de récupérer la durée (fiable) via YouTube Data v3.
    // On ne l'utilise que si Firestore n'a pas fourni readingTime.
    final videoId = _tryExtractYoutubeVideoId(detail);
    if (videoId != null && readingTimeFromFirestore == null) {
      final durationService = YoutubeDurationService(apiKey: _youtubeApiKey);
      final seconds = await durationService.fetchDurationSeconds(videoId);
      if (seconds != null && seconds > 0) {
        readingTime = (seconds / 60).ceil().clamp(1, 240);
      }
    }

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
      description: description,
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

  ///TODO: Améliorer en fonction des besoins réels.
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

  int? _asInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    if (raw is num) return raw.toInt();

    final s = raw.toString().trim();
    if (s.isEmpty) return null;

    // "5" -> 5 / "5.0" -> 5
    final asInt = int.tryParse(s);
    if (asInt != null) return asInt;

    final asDouble = double.tryParse(s.replaceAll(',', '.'));
    if (asDouble != null) return asDouble.round();

    return null;
  }

  String? _tryExtractYoutubeVideoId(String url) {
    final u = url.trim();
    if (u.isEmpty) return null;

    final uri = Uri.tryParse(u);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();

    // youtu.be/<id>
    if (host == 'youtu.be') {
      final seg = uri.pathSegments;
      if (seg.isEmpty) return null;
      final id = seg.first.trim();
      return id.isEmpty ? null : id;
    }

    // youtube.com/watch?v=<id>
    if (host.contains('youtube.com')) {
      final v = uri.queryParameters['v']?.trim();
      if (v != null && v.isNotEmpty) return v;

      // youtube.com/embed/<id>
      final seg = uri.pathSegments;
      final embedIndex = seg.indexOf('embed');
      if (embedIndex != -1 && embedIndex + 1 < seg.length) {
        final id = seg[embedIndex + 1].trim();
        return id.isEmpty ? null : id;
      }
    }

    return null;
  }
}
