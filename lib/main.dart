import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projet_sigh_grp1/pages/consumption/models/consumption_page.dart';
import 'pages/conseils/conseils_page.dart';
import 'package:projet_sigh_grp1/pages/settings/models/settings_page.dart';
import 'shared/firebase/firebase_options.dart';
import 'pages/home/home_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/notifications/notifications_history_page.dart';
import 'common-widget/navbar/navbar_widget.dart';
import 'common-widget/header/header_widget.dart';
import 'package:projet_sigh_grp1/pages/defis/defis_page.dart';
import 'pages/onboarding/onboarding_page.dart';
import 'shared/services/onboarding_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIGH Energies & Moi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF264777),
        ),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainNavigation(),
        '/profile': (context) => const ProfilePage(),
        '/notifications': (context) => const NotificationsHistoryPage(),
      },
    );
  }
}

/// Widget d'initialisation qui vérifie si l'onboarding est complété
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final hasCompleted = await OnboardingService.hasCompletedOnboarding();

    if (mounted) {
      if (hasCompleted) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF264777),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'SIGH Energies & Moi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2; // Démarrer sur la page Accueil

  final List<Map<String, dynamic>> _pages = [
    {'page': const DefisPage(), 'title': 'Défis'},
    {'page': const ConsumptionPage(), 'title': 'Analyse'},
    {'page': const HomePage(), 'title': 'Accueil'},
    {'page': const ConseilsPage(), 'title': 'Conseils'},
    {'page': const SettingsPage(), 'title': 'Paramètres'}
  ];

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex]['page'] as Widget,
      bottomNavigationBar: NavbarWidget(
        currentIndex: _currentIndex,
        onTap: _onNavbarTap,
      ),
    );
  }
}

class GenericPage extends StatelessWidget {
  final String title;

  const GenericPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: title,
              isHomePage: false,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Contenu de la page
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



