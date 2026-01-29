import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'models/content_model.dart';
import 'services/content_service.dart';

/// Page dédiée à un contenu YouTube, basée sur youtube_player_flutter.
///
/// On réutilise l'objet [ContentModel] pour afficher:
/// - catégorie / tags
/// - bouton favori
/// - description (fallback heuristique)
class ContentYoutubePage extends StatefulWidget {
  final ContentModel content;

  const ContentYoutubePage({
    super.key,
    required this.content,
  });

  @override
  State<ContentYoutubePage> createState() => _ContentYoutubePageState();
}

class _ContentYoutubePageState extends State<ContentYoutubePage> {
  final ContentService _contentService = ContentService();

  YoutubePlayerController? _controller;
  String? _error;

  late ContentModel _content;
  String? _videoId;

  Duration? _videoDuration;

  @override
  void initState() {
    super.initState();

    _content = widget.content;

    // Marquer comme lu automatiquement à l'ouverture
    if (_content.id != null && !_content.hasBeenRead) {
      _contentService.markAsRead(_content.id!);
      _content = _content.copyWith(hasBeenRead: true);
    }

    _videoId = YoutubePlayer.convertUrlToId(_content.pdfUrl);
    if (_videoId == null || _videoId!.isEmpty) {
      _error = 'Lien YouTube invalide: ${_content.pdfUrl}';
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        forceHD: false,
      ),
    )..addListener(_onPlayerTick);

    // La durée réelle est récupérée via le player (metadata) dès qu'elle devient dispo.
    // On persiste ensuite readingTime (en minutes) côté SQLite.
  }

  void _onPlayerTick() {
    final controller = _controller;
    if (controller == null) return;

    try {
      final d = controller.metadata.duration;
      if (d == Duration.zero) return;

      // Ne setState que si ça change réellement.
      if (_videoDuration != null && _videoDuration == d) return;

      _videoDuration = d;

      // Best-effort: sync readingTime (minutes) en DB.
      final id = _content.id;
      if (id != null) {
        final minutes = (d.inSeconds / 60).ceil().clamp(1, 240);
        if (minutes != _content.readingTime) {
          _contentService.updateReadingTime(id, minutes);
          _content = _content.copyWith(readingTime: minutes);
        }
      }

      if (!mounted) return;
      setState(() {});
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _content.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _content.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            tooltip: 'Partager',
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _share,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header BLEU pleine largeur
                  _buildHeader(),

                  // Player en pleine largeur (sans box)
                  YoutubePlayerBuilder(
                    player: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: const Color(0xFF003366),
                      progressColors: const ProgressBarColors(
                        playedColor: Color(0xFF003366),
                        handleColor: Color(0xFF003366),
                      ),
                    ),
                    builder: (context, player) {
                      return SizedBox(
                        width: double.infinity,
                        child: player,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description sans carte grise
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final tags = _content.getTagsList();

    return Container(
      width: double.infinity,
      color: const Color(0xFF003366),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Catégorie (pill)
          if (_content.category.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Text(
                _content.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          if (_content.category.trim().isNotEmpty && tags.isNotEmpty) const SizedBox(width: 10),

          // Tags sur la même ligne (scroll horizontal si trop)
          if (tags.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final description = _deriveDescription(_content);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne infos: durée vidéo (si connue) + temps estimé (minutes)
          if (_videoDuration != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Color(0xFF003366)),
                  const SizedBox(width: 6),
                  Text(
                    'Durée vidéo : ${_formatDuration(_videoDuration!)}',
                    style: const TextStyle(
                      color: Color(0xFF003366),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const Text(
            'Description',
            style: TextStyle(
              color: Color(0xFF003366),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  /// Utilise `content.description` si présent (synchro Firestore -> SQLite).
  /// Fallback léger si vide.
  String _deriveDescription(ContentModel content) {
    final raw = content.description.trim();
    if (raw.isNotEmpty) return raw;

    final tags = content.getTagsList();
    final tagsText = tags.isEmpty ? 'Aucun tag' : tags.take(6).join(', ');

    return 'Catégorie : ${content.category}\n\n'
        'Tags : $tagsText\n\n'
        'Ce contenu sera bientôt enrichi avec une description complète depuis Firebase.';
  }

  Future<void> _toggleFavorite() async {
    final id = _content.id;
    if (id == null) return;

    final next = await _contentService.toggleFavoriteById(id);
    if (!mounted) return;
    setState(() {
      _content = _content.copyWith(isFavorite: next);
    });
  }

  Future<void> _share() async {
    try {
      await Share.share(_content.pdfUrl, subject: _content.title);
    } catch (_) {
      // ignore
    }
  }
}
