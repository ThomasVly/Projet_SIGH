import 'package:flutter/material.dart';
import 'database_test_page.dart';
import 'pages/home/home_page.dart';
import 'common-widget/navbar/navbar_widget.dart';

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
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Scaffold(backgroundColor: Colors.white, body: SizedBox.expand()),
    const Scaffold(backgroundColor: Colors.white, body: SizedBox.expand()),
    const Scaffold(backgroundColor: Colors.white, body: SizedBox.expand()),
    const Scaffold(backgroundColor: Colors.white, body: SizedBox.expand()),
  ];

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavbarWidget(
        currentIndex: _currentIndex,
        onTap: _onNavbarTap,
      ),
    );
  }
}
