import 'dart:convert';

import 'package:http/http.dart' as http;

/// Récupère la durée d'une vidéo YouTube sans avoir besoin d'ouvrir le player.
///
/// Stratégie:
/// - si une clé API est fournie (par ex via --dart-define=YOUTUBE_API_KEY=...),
///   on utilise l'API YouTube Data v3 (endpoint videos) -> durée fiable.
/// - sinon, on renvoie null (on ne peut pas obtenir la durée de façon fiable).
class YoutubeDurationService {
  const YoutubeDurationService({required this.apiKey});

  /// Clé API YouTube Data v3. Peut être vide.
  final String apiKey;

  /// Retourne la durée en secondes (null si pas dispo).
  Future<int?> fetchDurationSeconds(String videoId) async {
    if (apiKey.trim().isEmpty) return null;

    final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'contentDetails',
      'id': videoId,
      'key': apiKey,
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final jsonBody = json.decode(res.body);
    if (jsonBody is! Map<String, dynamic>) return null;

    final items = jsonBody['items'];
    if (items is! List || items.isEmpty) return null;

    final first = items.first;
    if (first is! Map<String, dynamic>) return null;

    final contentDetails = first['contentDetails'];
    if (contentDetails is! Map<String, dynamic>) return null;

    final durationIso = contentDetails['duration'];
    if (durationIso is! String || durationIso.trim().isEmpty) return null;

    final seconds = _parseIso8601DurationToSeconds(durationIso);
    return seconds;
  }

  /// Parse une durée ISO8601 (ex: PT1H2M3S) en seconds.
  /// Supporte H/M/S (ordre standard). Retourne null si invalide.
  int? _parseIso8601DurationToSeconds(String iso) {
    // Format attendu: PT#H#M#S avec segments optionnels.
    final r = RegExp(r'^PT(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+)S)?$');
    final m = r.firstMatch(iso.trim());
    if (m == null) return null;

    final h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final s = int.tryParse(m.group(3) ?? '0') ?? 0;

    return h * 3600 + min * 60 + s;
  }
}

