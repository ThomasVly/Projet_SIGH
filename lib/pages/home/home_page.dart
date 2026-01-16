import 'package:flutter/material.dart';
import '../../shared/local_database/db-creator.dart';
import '../../common-widget/header/header_widget.dart';
import '../conseils/services/content_service.dart';
import '../equipments/services/equipment_service.dart';
import 'components/home_chart_widget.dart';
import 'components/home_reminder_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Services & Data
  final ContentService _contentService = ContentService();
  final EquipmentService _equipmentService = EquipmentService();
  final ScrollController _scrollController = ScrollController();

  // Stats pour le dashboard
  InventoryStats _stats = InventoryStats(
    monthlyConsumption: 0,
    monthlyCost: 0,
    equipmentCount: 0,
    totalConsumption: 0,
  );

  // Liste des rappels (Simulée pour l'instant car pas de Service complet pour les rappels)
  // Mets cette liste à vide [] pour tester l'affichage du "rectangle à la place"
  final List<Map<String, String>> _reminders = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Colors.grey.withOpacity(0.4),
        thickness: 1,
        indent: 40,
        endIndent: 40,
      ),
    );
  }

  Future<void> _loadData() async {
    // 1. Récupérer les vraies stats de consommation
    final stats = await _equipmentService.getInventoryStats();

    // 2. (Optionnel) Ici tu pourrais charger les vrais rappels depuis la BDD
    // final reminders = await ...

    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le body est un Stack pour gérer l'image de fond fixe
      extendBody: true,
      body: Stack(
        children: [
          // 1. Image d'arrière-plan fixe
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // Assure-toi d'avoir cette image ou change le nom
              fit: BoxFit.cover,
            ),
          ),

          // 2. Contenu scrollable par-dessus
          Column(
            children: [
              // --- HEADER ---
              HeaderWidget(
                userName: 'Clara',
                isHomePage: true,
                navigationContext: context,
              ),

              Expanded(
                child: SingleChildScrollView(
                controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // --- SECTION 1: DASHBOARD ---
                      const Text(
                        'Ton suivi de consommation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF264777),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1. Le Graphe FL_CHART
                      const HomeChartWidget(),

                      _buildSectionDivider(),
                      const SizedBox(height: 12),

                      // --- SECTION 2: RAPPELS ou ENCART ALTERNATIF ---
                      const HomeReminderSection(),
                      _buildSectionDivider(),
                      const SizedBox(height: 32),

                      // --- SECTION 3: DÉFI DU MOIS ---
                      const Text(
                        'Défi du mois',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF264777),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMonthlyChallengeCard(),

                      // Espace en bas pour le scroll
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// Carte du Défi du mois
  Widget _buildMonthlyChallengeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF72BA00), Color(0xFF5E9A00)], // Vert énergie
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF72BA00).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigation vers la page défis
            // Navigator.push(...);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Illustration ou Icône
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '🏆',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),

                // Textes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Objectif -10%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Réduisez votre conso de chauffage ce mois-ci pour gagner le badge "Polaire" !',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Barre de progression simulée
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.65, // 65%
                          backgroundColor: Colors.black.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
