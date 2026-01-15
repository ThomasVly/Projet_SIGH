import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'models/content_model.dart';
import 'services/content_service.dart';
import 'content_webview_page.dart';
import 'content_youtube_page.dart';

/// Page de détail d'un contenu (article, fiche, tutoriel)
class ContentDetailPage extends StatefulWidget {
  final ContentModel content;

  const ContentDetailPage({
    super.key,
    required this.content,
  });

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final ContentService _contentService = ContentService();
  String? _localPdfPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  late final _ContentLinkKind _linkKind;
  late ContentModel _content;

  @override
  void initState() {
    super.initState();

    _content = widget.content;

    // Marquer comme lu automatiquement à l'ouverture
    if (!_content.hasBeenRead) {
      _contentService.markAsRead(_content.id!);
      _content = _content.copyWith(hasBeenRead: true);
    }

    _linkKind = _detectLinkKind(_content.pdfUrl);

    // Si ce n'est pas un PDF, on bascule vers une page Web (ou YouTube).
    // On le fait après le premier frame pour ne pas pousser une route pendant build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_linkKind == _ContentLinkKind.web) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ContentWebViewPage(
              title: widget.content.title,
              url: widget.content.pdfUrl,
              contentId: widget.content.id,
              initialIsFavorite: widget.content.isFavorite,
            ),
          ),
        );
        return;
      }

      if (_linkKind == _ContentLinkKind.youtube) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ContentYoutubePage(
              content: widget.content,
            ),
          ),
        );
        return;
      }

      // PDF
      _loadPdf();
    });
  }

  _ContentLinkKind _detectLinkKind(String url) {
    final u = url.trim();
    if (u.isEmpty) return _ContentLinkKind.unknown;

    final lower = u.toLowerCase();

    // Assets (ex: assets/files/PDF_example.pdf)
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return _ContentLinkKind.pdf;
    }

    // YouTube
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return _ContentLinkKind.youtube;
    }

    // PDF distant
    if (lower.contains('.pdf')) {
      return _ContentLinkKind.pdf;
    }

    // Sinon, web
    return _ContentLinkKind.web;
  }

  /// Charge le PDF (depuis les assets ou depuis une URL)
  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final pdfUrl = widget.content.pdfUrl;

      if (pdfUrl.isEmpty) {
        setState(() {
          _errorMessage = 'Aucun PDF disponible pour ce contenu';
          _isLoading = false;
        });
        return;
      }

      // Garde-fou: si jamais on arrive ici avec un lien non-PDF, on n'essaye pas de le charger en PDF.
      final kind = _detectLinkKind(pdfUrl);
      if (kind != _ContentLinkKind.pdf) {
        setState(() {
          _errorMessage = 'Ce contenu n\'est pas un PDF.';
          _isLoading = false;
        });
        return;
      }

      // Si c'est une URL distante, télécharger le PDF
      if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
        final response = await http.get(Uri.parse(pdfUrl));

        if (response.statusCode == 200) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/temp_${widget.content.id}.pdf');
          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            _localPdfPath = file.path;
            _isLoading = false;
          });
        } else {
          throw Exception('Erreur de téléchargement du PDF (status ${response.statusCode})');
        }
      }
      // Si c'est un asset local Flutter
      else {
        // Copier l'asset dans un fichier temporaire car PDFView ne peut pas lire directement depuis les assets
        final byteData = await rootBundle.load(pdfUrl);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/asset_${widget.content.id}.pdf');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du PDF: $e';
        _isLoading = false;
      });
    }
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
          _content.category,
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et informations
          _buildHeader(),

          // Contenu PDF
          Expanded(
            child: _buildPdfViewer(),
          ),
        ],
      ),
    );
  }

  /// Construit le header de la page
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF003366),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            _content.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Informations (temps de lecture, économie)
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${_content.readingTime} min de lecture',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.eco, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'Économie ~${_content.notation * 2}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),

          // Tags
          if (_content.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _content.getTagsList().map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit le viewer PDF
  Widget _buildPdfViewer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF003366),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement du PDF...',
              style: TextStyle(
                color: Color(0xFF003366),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_localPdfPath == null) {
      return const Center(
        child: Text(
          'Aucun PDF disponible',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Viewer PDF
        PDFView(
          filePath: _localPdfPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.WIDTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = 'Erreur lors de l\'affichage du PDF: $error';
            });
          },
          onPageError: (page, error) {
            print('Erreur page $page: $error');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // Contrôleur PDF disponible si besoin
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              _currentPage = page ?? 0;
              _totalPages = total ?? 0;
            });
          },
        ),

        // Indicateur de page - bulle en haut à droite
        if (_totalPages > 0)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF003366),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_currentPage + 1}/$_totalPages',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Toggle le favori
  Future<void> _toggleFavorite() async {
    final id = _content.id;
    if (id == null) return;

    final next = await _contentService.toggleFavoriteById(id);

    if (!mounted) return;
    setState(() {
      _content = _content.copyWith(isFavorite: next);
    });
  }
}

enum _ContentLinkKind { pdf, web, youtube, unknown }
