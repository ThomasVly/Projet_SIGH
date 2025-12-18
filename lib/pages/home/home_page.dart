import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';
import '../../shared/local_database/db-creator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    bool isCollapsed = _scrollController.offset > 20;
    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _resetDatabase(BuildContext context) async {
    // Afficher une boîte de dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser la base de données'),
          content: const Text(
            'Êtes-vous sûr de vouloir réinitialiser la base de données ? '
            'Toutes les données seront supprimées et vous devrez redémarrer l\'application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Réinitialiser la base de données
        await DatabaseHelper.instance.resetDatabase();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Base de données réinitialisée ! Veuillez redémarrer l\'application.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la réinitialisation : $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: HeaderWidget(
              userName: 'Clara',
              isHomePage: true,
              isCollapsed: _isCollapsed,
              navigationContext: context,
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 16),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Ajouter vos widgets ici
                  ElevatedButton.icon(
                    onPressed: () => _resetDatabase(context),
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text('TEMP: Reset Database'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '⚠️ Bouton temporaire de test',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

