import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'models/content_model.dart';
import 'services/content_service.dart';

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

  @override
  void initState() {
    super.initState();
    // Marquer comme lu automatiquement à l'ouverture
    if (!widget.content.hasBeenRead) {
      _contentService.markAsRead(widget.content.id!);
    }
    _loadPdf();
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
          throw Exception('Erreur de téléchargement du PDF');
        }
      }
      // Si c'est un chemin local (assets)
      else {
        setState(() {
          _localPdfPath = pdfUrl;
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
          widget.content.category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.content.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () => _toggleFavorite(),
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
            widget.content.title,
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
                '${widget.content.readingTime} min de lecture',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.eco, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'Économie ~${widget.content.notation * 2}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),

          // Tags
          if (widget.content.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.content.getTagsList().map((tag) {
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

    return Column(
      children: [
        // Indicateur de page
        if (_totalPages > 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFFF5F5F5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, color: Color(0xFF003366), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Page ${_currentPage + 1} sur $_totalPages',
                  style: const TextStyle(
                    color: Color(0xFF003366),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Viewer PDF
        Expanded(
          child: PDFView(
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
        ),
      ],
    );
  }

  /// Toggle le favori
  Future<void> _toggleFavorite() async {
    await _contentService.toggleFavorite(
      widget.content.id!,
      !widget.content.isFavorite,
    );
    setState(() {
      // Mise à jour locale pour éviter de recharger
    });
  }
}
