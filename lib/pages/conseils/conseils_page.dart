import 'package:flutter/material.dart';
import '../../shared/local_database/models/content_model.dart';
import '../../shared/local_database/services/content_service.dart';
import '../../shared/local_database/fake_data/content_fake_data.dart';

/// Page des conseils avec onglets Fiches infos et Tutoriels
class ConseilsPage extends StatefulWidget {
  const ConseilsPage({super.key});

  @override
  State<ConseilsPage> createState() => _ConseilsPageState();
}

class _ConseilsPageState extends State<ConseilsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentService _contentService = ContentService();
  List<ContentModel> _fiches = [];
  List<ContentModel> _tutoriels = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Charge les données depuis la base de données
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Remplir la base si vide
    await ContentFakeData.populateDatabase();
    
    // Charger les fiches et tutoriels
    final fiches = await _contentService.getContentsByType('fiche');
    final tutoriels = await _contentService.getContentsByType('tutorial');
    
    setState(() {
      _fiches = fiches;
      _tutoriels = tutoriels;
      _isLoading = false;
    });
  }

  /// Filtre les contenus selon la recherche
  List<ContentModel> _filterContents(List<ContentModel> contents) {
    if (_searchQuery.isEmpty) return contents;
    
    return contents.where((content) {
      return content.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             content.tags.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        elevation: 0,
        title: const Text(
          'Conseils',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Fiches infos'),
            Tab(text: 'Tutoriels'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildContentList(_filterContents(_fiches)),
                _buildContentList(_filterContents(_tutoriels)),
              ],
            ),
    );
  }

  /// Construit la liste de contenus
  Widget _buildContentList(List<ContentModel> contents) {
    if (contents.isEmpty) {
      return const Center(
        child: Text(
          'Aucun contenu disponible',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        return _buildContentCard(contents[index]);
      },
    );
  }

  /// Construit une carte de contenu
  Widget _buildContentCard(ContentModel content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showContentDetail(content),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  content.type == 'fiche' ? Icons.article : Icons.play_circle_outline,
                  size: 30,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.tags,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Icône favori
              IconButton(
                icon: Icon(
                  content.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: content.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(content),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche le détail d'un contenu
  void _showContentDetail(ContentModel content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de drag
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Titre
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: content.getTagsList().map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: const Color(0xFF003366).withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: Color(0xFF003366),
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Notation
                  Row(
                    children: [
                      const Text('Note : ', style: TextStyle(fontWeight: FontWeight.w600)),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < content.notation ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  // Contenu (exemple)
                  const Text(
                    'Description du contenu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ceci est un exemple de contenu. Dans une version complète, vous pourriez ajouter un champ "content" ou "description" dans votre modèle ContentModel pour afficher le contenu réel de l\'article ou du tutoriel.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  // Bouton pour marquer comme lu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _markAsRead(content);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        content.hasBeenRead ? 'Déjà lu' : 'Marquer comme lu',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Toggle le favori
  Future<void> _toggleFavorite(ContentModel content) async {
    await _contentService.toggleFavorite(content.id!, !content.isFavorite);
    _loadData();
  }

  /// Marque comme lu
  Future<void> _markAsRead(ContentModel content) async {
    if (!content.hasBeenRead) {
      await _contentService.markAsRead(content.id!);
      _loadData();
    }
  }

  /// Affiche le dialogue de recherche
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = _searchQuery;
        return AlertDialog(
          title: const Text('Rechercher'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Titre ou tags...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => query = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = '');
                Navigator.pop(context);
              },
              child: const Text('Effacer'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = query);
                Navigator.pop(context);
              },
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    );
  }
}

