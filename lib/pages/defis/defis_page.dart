import 'package:flutter/material.dart';
import 'package:projet_sigh_grp1/common-widget/header/header_widget.dart';
import 'package:projet_sigh_grp1/pages/defis/defis_menu_page.dart';

class DefisPage extends StatelessWidget {
  const DefisPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,
      body: Stack(
        children:[
          // 1. Image d'arrière-plan fixe
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: const [
              HeaderWidget(
                title: 'Défis',
                isHomePage: false,
                isConseilsPage: false,
              ),
              SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: DefisMenuPage(), // 👉 le menu (Quiz / Défis / Stats)
                ),
              ),
            ],
          ),
        ]
      ),
    );
  }
}
