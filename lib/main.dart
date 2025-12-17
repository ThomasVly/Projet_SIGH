import 'package:flutter/material.dart';
import 'pages/home/home_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/notifications/notifications_history_page.dart';
import 'common-widget/navbar/navbar_widget.dart';
import 'common-widget/header/header_widget.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavigation(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/notifications': (context) => const NotificationsHistoryPage(),
      },
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
    {'page': const GenericPage(title: 'Défis'), 'title': 'Défis'},
    {'page': const GenericPage(title: 'Analyse'), 'title': 'Analyse'},
    {'page': const HomePage(), 'title': 'Accueil'},
    {'page': const GenericPage(title: 'Conseils'), 'title': 'Conseils'},
    {'page': const GenericPage(title: 'Paramètres'), 'title': 'Paramètres'}
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



