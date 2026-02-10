import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';
import '../../shared/services/onboarding_service.dart';
import '../Rappel/rappel_page.dart';
import '../conseils/services/content_service.dart';
import '../equipments/services/equipment_service.dart';
import 'components/home_chart_widget_SHARED.dart';
import 'components/home_reminder_section_PRIORITY.dart';
import '../defis/models/challenge_models.dart';
import '../../shared/firebase/firestore_service.dart';
import '../defis/defi_mensuel_page.dart';
import '../Rappel/models/reminder.dart';
import 'dart:convert'; // Pour jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Services & Data
  String _userName = 'clara';
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

  ChallengeDefinition? _monthlyChallenge; // Stocke le défi récupéré
  bool _isLoadingChallenge = true;        // Gère l'état de chargement

  // Liste des rappels (Simulée pour l'instant car pas de Service complet pour les rappels)
  // Mets cette liste à vide [] pour tester l'affichage du "rectangle à la place"

  // Variables pour les rappels
  List<Reminder> _reminders = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await OnboardingService.getUserName();
    setState(() {
      _userName = name;
    });
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

    // 2. Rappels (Depuis shared preferencies)
    List<Reminder> loadedReminders = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? remindersJson = prefs.getString('reminders');

      if (remindersJson != null && remindersJson.isNotEmpty) {
        // On décode le JSON (String -> List<dynamic>)
        final List<dynamic> decodedList = jsonDecode(remindersJson);

        // On convertit chaque élément en objet Reminder
        loadedReminders = decodedList
            .map((json) => Reminder.fromJson(json))
            .toList();

        // Optionnel : Trier par heure (scheduledTime)
        loadedReminders.sort((a, b) {
          if (a.scheduledTime == null) return 1;
          if (b.scheduledTime == null) return -1;
          return a.scheduledTime!.compareTo(b.scheduledTime!);
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement rappels SharedPreferences: $e");
    }
    // 3. Défi du mois (Depuis Firestore)
    ChallengeDefinition? challengeFound;
    try {
      // On utilise exactement la même méthode que DefiMensuelPage
      final rawList = await FirestoreService.getChallenges();

      // Conversion en objets
      final definitions = rawList.map((data) {
        return ChallengeDefinition.fromFirestore(data, data['id'] as String);
      }).toList();

      if (definitions.isNotEmpty) {
        // On cherche le défi du mois courant (isCurrent == true)
        // Sinon on prend le premier de la liste par défaut
        challengeFound = definitions.firstWhere(
              (def) => def.isCurrent,
          orElse: () => definitions.first,
        );
      }
    } catch (e) {
      debugPrint('Erreur chargement défi home: $e');
    }
    if (mounted) {
      setState(() {
        _stats = stats;
        _reminders = loadedReminders;
        _monthlyChallenge = challengeFound;
        _isLoadingChallenge = false;
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
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Contenu scrollable par-dessus
          Column(
            children: [
              // --- HEADER ---
              HeaderWidget(
                userName: _userName,
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

                      // --- SECTION 2: RAPPELS
                      HomeReminderSection(reminders: _reminders,
                        onSettingsTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RappelPage()),
                          );
                          _loadData(); // ✅ Recharge les données
                        },
                      ),
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
    if (_isLoadingChallenge) {
      return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator())
      );
    }

    // Cas où aucun défi n'est trouvé
    if (_monthlyChallenge == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text("Aucun défi disponible pour ce mois.")),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF264777), Color(0xFF264777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF264777).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DefiMensuelPage()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [

                const SizedBox(width: 16),

                // Textes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        _monthlyChallenge!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _monthlyChallenge!.description, // Description dynamique
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 12),

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
