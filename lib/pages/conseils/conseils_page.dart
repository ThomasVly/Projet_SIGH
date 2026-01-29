import 'package:flutter/material.dart';
import 'models/content_model.dart';
import 'services/content_service.dart';
import 'content_detail_page.dart';
import 'services/content_sync_service.dart';
import 'conseils_settings_page.dart';
import '../../shared/navigation/route_observer.dart';
import 'services/conseils_preferences_service.dart';

/// TODO: Fix le bug qui clear l'article à la une quand on change d'onglet puis revient.
/// TODO: Séparer l'article à la une du tuto à la une (actuellement c'est le même pour les deux onglets).
/// TODO: Séparer les filtres des articles des filtres des tutoriels (actuellement c'est le même pour les deux onglets).
/// TODO: Changer l'affichage rose gris bizarre des cadres.
///

/// Page des conseils avec onglets Fiches infos et Tutoriels
class ConseilsPage extends StatefulWidget {
  const ConseilsPage({super.key});

  @override
  State<ConseilsPage> createState() => _ConseilsPageState();
}

class _ConseilsPageState extends State<ConseilsPage>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  final ContentService _contentService = ContentService();
  final ContentSyncService _contentSyncService = ContentSyncService();
  final ConseilsPreferencesService _prefs = ConseilsPreferencesService();

  List<ContentModel> _fiches = [];
  List<ContentModel> _tutoriels = [];
  ContentModel? _featuredContent;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedTag;
  List<String> _availableTags = [];

  // Optionnel: stocker localement si tu veux conditionner l'UI/les filtres
  String? _heatingType;
  String? _heatingEnergy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _refreshConseilsPreferences();
  }

  @override
  void didPopNext() {
    // Appelé quand on revient sur cette page (ex: retour depuis paramètres)
    _refreshConseilsPreferences();
  }

  Future<void> _refreshConseilsPreferences() async {
    final heatingType = await _prefs.getHeatingType();
    final heatingEnergy = await _prefs.getHeatingEnergy();

    if (!mounted) return;
    setState(() {
      _heatingType = heatingType;
      _heatingEnergy = heatingEnergy;
    });
  }

  Future<void> _syncFromFirestoreAndReload() async {
    setState(() => _isLoading = true);

    try {
      final synced = await _contentSyncService.syncFromFirestore();

      // Recharger depuis SQLite
      final fiches = await _contentService.getContentsByType('fiche');
      final tutoriels = await _contentService.getContentsByType('tutorial');
      final featured = await _contentService.getFeaturedContent();
      final tags = await _contentService.getAllTags();

      setState(() {
        _fiches = fiches;
        _tutoriels = tutoriels;
        _featuredContent = featured;
        _availableTags = tags;
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync Firestore terminée ($synced contenus).')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync Firestore impossible: $e')),
      );
    }
  }

  /// Charge les données depuis la base de données
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 1) Sync Firestore -> SQLite (source unique)
      await _contentSyncService.syncFromFirestore();

      // 2) Charger les fiches et tutoriels depuis SQLite
      final fiches = await _contentService.getContentsByType('fiche');
      final tutoriels = await _contentService.getContentsByType('tutorial');
      final featured = await _contentService.getFeaturedContent();
      final tags = await _contentService.getAllTags();

      setState(() {
        _fiches = fiches;
        _tutoriels = tutoriels;
        _featuredContent = featured;
        _availableTags = tags;
        _isLoading = false;
      });
    } catch (e) {
      // Si erreur de colonne manquante, réinitialiser la base de données
      if (e.toString().contains('no such column')) {
        print('Colonnes manquantes détectées, réinitialisation de la base de données...');

        await _contentService.resetDatabase();
        await _contentSyncService.syncFromFirestore();

        final fiches = await _contentService.getContentsByType('fiche');
        final tutoriels = await _contentService.getContentsByType('tutorial');
        final featured = await _contentService.getFeaturedContent();
        final tags = await _contentService.getAllTags();

        setState(() {
          _fiches = fiches;
          _tutoriels = tutoriels;
          _featuredContent = featured;
          _availableTags = tags;
          _isLoading = false;
        });
      } else {
        // Firestore indisponible ou autre: on affiche ce qui est déjà en cache SQLite
        print('Erreur lors du chargement des données: $e');

        final fiches = await _contentService.getContentsByType('fiche');
        final tutoriels = await _contentService.getContentsByType('tutorial');
        final featured = await _contentService.getFeaturedContent();
        final tags = await _contentService.getAllTags();

        setState(() {
          _fiches = fiches;
          _tutoriels = tutoriels;
          _featuredContent = featured;
          _availableTags = tags;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Firestore indisponible: $e')),
          );
        }
      }
    }
  }

  Future<void> _resetDbAndReload() async {
    setState(() => _isLoading = true);

    try {
      await _contentService.resetDatabase();
      await _contentSyncService.syncFromFirestore();
      await _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base de données réinitialisée. Synchronisation Firestore effectuée.')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur reset DB: $e')),
      );
    }
  }

  /// Filtre les contenus selon la recherche, le tag sélectionné
  /// et les préférences chauffage (type/énergie).
  List<ContentModel> _filterContents(List<ContentModel> contents) {
    var filtered = contents;

    // Filtre par préférences chauffage
    filtered = filtered.where(_matchesHeatingPreferences).toList();

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((content) {
        return content.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            content.tags.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtre par tag
    if (_selectedTag != null) {
      filtered = filtered.where((content) {
        return content.getTagsList().contains(_selectedTag);
      }).toList();
    }

    return filtered;
  }

  bool _matchesHeatingPreferences(ContentModel content) {
    // Si aucune préférence n'est définie: on laisse tout passer.
    if (_heatingType == null && _heatingEnergy == null) return true;

    final tagsLower = content
        .getTagsList()
        .map((t) => t.toLowerCase())
        .toList(growable: false);

    // Type de chauffage: on masque l'opposé
    // Ex: collectif => masque tout contenu taggé "chauffage individuel"
    if (_heatingType == 'collectif') {
      if (tagsLower.contains('chauffage individuel')) return false;
    } else if (_heatingType == 'individuel') {
      if (tagsLower.contains('chauffage collectif')) return false;
    }

    // Énergie de chauffage: on masque l'opposé
    // Ex: electrique => masque "chauffage gaz" (et variantes)
    if (_heatingEnergy == 'electrique') {
      if (tagsLower.contains('chauffage gaz') || tagsLower.contains('gaz')) {
        return false;
      }
    } else if (_heatingEnergy == 'gaz') {
      if (tagsLower.contains('chauffage électrique') ||
          tagsLower.contains('chauffage electrique') ||
          tagsLower.contains('électrique') ||
          tagsLower.contains('electrique')) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF003366)))
          : Column(
              children: [
                // Header bleu foncé avec titre "Conseils" uniquement
                _buildHeader(
                  onTempResetDbPressed: _resetDbAndReload,
                ),
                // Onglets Fiches infos / Tutoriels
                _buildTabs(),
                // Barre de recherche (sous les onglets)
                _buildSearchBar(),
                // Contenu avec onglets
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(_filterContents(_fiches)),
                      _buildTabContent(_filterContents(_tutoriels)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Construit le header bleu avec titre uniquement
  Widget _buildHeader({VoidCallback? onTempResetDbPressed}) {
    return Container(
      color: const Color(0xFF003366),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Conseils',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                tooltip: 'Paramètres des conseils',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ConseilsSettingsPage(),
                    ),
                  );
                  // Refresh immédiat au retour.
                  await _refreshConseilsPreferences();
                },
              ),
              // TEMP: force la sync Firestore -> SQLite
              IconButton(
                icon: const Icon(Icons.cloud_download, color: Colors.white, size: 28),
                onPressed: _syncFromFirestoreAndReload,
                tooltip: 'Sync Firestore',
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                onPressed: onTempResetDbPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit les onglets Fiches infos / Tutoriels
  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF003366),
        indicatorWeight: 3,
        labelColor: const Color(0xFF003366),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Fiches infos'),
          Tab(text: 'Tutoriels'),
        ],
      ),
    );
  }

  /// Construit la barre de recherche (sous les onglets)
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          decoration: InputDecoration(
            hintText: 'Rechercher un conseil...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  /// Construit le contenu d'un onglet
  Widget _buildTabContent(List<ContentModel> contents) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags de recherche
          _buildTagsRow(),

          // Article à la une (uniquement dans Fiches infos)
          if (_tabController.index == 0 && _featuredContent != null)
            _buildFeaturedArticle(_featuredContent!),

          // Liste des articles
          if (contents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Aucun contenu disponible',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                return _buildContentCard(contents[index]);
              },
            ),
        ],
      ),
    );
  }

  /// Construit la rangée de tags
  Widget _buildTagsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTagChip('Tous', null),
          ..._availableTags.take(10).map((tag) => _buildTagChip(tag, tag)),
        ],
      ),
    );
  }

  /// Construit un chip de tag
  Widget _buildTagChip(String label, String? tagValue) {
    final isSelected = _selectedTag == tagValue;
    final icon = _getTagIcon(label);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedTag = selected ? tagValue : null;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF003366).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF003366) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF003366) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  /// Retourne l'icône pour un tag
  String? _getTagIcon(String tag) {
    final tagLower = tag.toLowerCase();
    if (tagLower.contains('chauffage')) return '🔥';
    if (tagLower.contains('économie')) return '💰';
    if (tagLower.contains('électric') || tagLower.contains('electric')) return '💡';
    if (tagLower.contains('éclairage')) return '💡';
    return null;
  }

  /// Construit l'article à la une
  Widget _buildFeaturedArticle(ContentModel content) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003366),
            Color(0xFF0055AA),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003366).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showContentDetail(content),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge "À la une"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'À la une',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Titre
                Text(
                  content.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  'Découvrez les actions concrètes à mettre en place dès aujourd\'hui pour réduire significativement votre consommation d\'énergie.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton "Lire l'article"
                ElevatedButton(
                  onPressed: () => _showContentDetail(content),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Lire l\'article',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit une carte de contenu
  Widget _buildContentCard(ContentModel content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showContentDetail(content),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de catégorie
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF003366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    content.getCategoryIcon(),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Catégorie
                    Row(
                      children: [
                        Text(
                          content.getCategoryIcon(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Titre
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003366),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Temps de lecture et économie
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${content.readingTime} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.eco, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Économie ~${content.notation * 2}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche le détail d'un contenu
  void _showContentDetail(ContentModel content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailPage(content: content),
      ),
    ).then((_) {
      // Recharger les données après le retour pour mettre à jour les statuts (lu/favori)
      _loadData();
    });
  }
}
