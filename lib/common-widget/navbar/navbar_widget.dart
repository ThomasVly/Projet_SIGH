import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavbarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.extension),
                label: 'Quizz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Analyse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                label: 'Conseils',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Paramètres',
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: (MediaQuery.of(context).size.width / 5) * currentIndex,
            child: Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF001F5C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

