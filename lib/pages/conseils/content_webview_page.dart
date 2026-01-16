import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'services/content_service.dart';

///TODO : Fix ERR_TIMEOUT
/// WebView générique pour afficher une ressource web (article HTML, PDF en preview, etc.).
class ContentWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  /// Si le lien WebView correspond à un contenu local, on peut gérer le favori.
  final int? contentId;
  final bool? initialIsFavorite;

  const ContentWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.contentId,
    this.initialIsFavorite,
  });

  @override
  State<ContentWebViewPage> createState() => _ContentWebViewPageState();
}

class _ContentWebViewPageState extends State<ContentWebViewPage> {
  final ContentService _contentService = ContentService();

  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _didFallbackToExternal = false;
  bool _isInfoMessage = false;

  late bool _isFavorite;

  Uri get _initialUri => Uri.parse(widget.url);

  @override
  void initState() {
    super.initState();

    _isFavorite = widget.initialIsFavorite ?? false;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        // UA mobile "standard" pour éviter certains blocages de contenu.
        'Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) async {
            if (!mounted) return;
            setState(() => _isLoading = false);

            try {
              await _controller.runJavaScript('window.__flutter = true;');
            } catch (_) {
              // ignore
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            final scheme = uri.scheme.toLowerCase();
            if (scheme != 'http' && scheme != 'https') {
              _openExternal(uri);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            final description = error.description;
            if (!mounted) return;

            if (description.contains('net::ERR_BLOCKED_BY_ORB')) {
              _handleOrbBlocked();
              return;
            }

            setState(() {
              _isInfoMessage = false;
              _error = description;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(_initialUri);
  }

  Future<void> _handleOrbBlocked() async {
    if (_didFallbackToExternal) return;
    _didFallbackToExternal = true;

    await _openExternal(_initialUri);

    if (!mounted) return;
    setState(() {
      _isInfoMessage = true;
      _error =
          'Ce site ne peut pas être affiché directement dans l\'application.\n\nNous avons ouvert votre tutoriel dans votre navigateur.';
      _isLoading = false;
    });
  }

  Future<void> _openExternal(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _toggleFavorite() async {
    final id = widget.contentId;
    if (id == null) return;

    final next = await _contentService.toggleFavoriteById(id);

    if (!mounted) return;
    setState(() {
      _isFavorite = next;
    });
  }

  Future<void> _share() async {
    final url = widget.url;
    try {
      await Share.share(url, subject: widget.title);
    } catch (_) {
      // fallback: copy
      await Clipboard.setData(ClipboardData(text: url));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien copié dans le presse-papiers.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageColor = _isInfoMessage ? const Color(0xFF003366) : Colors.red;
    final messageTitle = _isInfoMessage ? 'Information' : 'Erreur lors du chargement';

    final canFavorite = widget.contentId != null;

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
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (canFavorite)
            IconButton(
              tooltip: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
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
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$messageTitle:\n$_error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: messageColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openExternal(_initialUri),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Ouvrir dans le navigateur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF003366),
              backgroundColor: Color(0xFFE6EEF7),
            ),
        ],
      ),
    );
  }
}
