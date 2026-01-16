import 'package:flutter/material.dart';
import 'package:projet_sigh_grp1/common-widget/header/header_widget.dart';
import 'package:projet_sigh_grp1/pages/settings/models/help_page.dart';
import 'package:projet_sigh_grp1/pages/settings/models/privacy_page.dart';
import 'package:projet_sigh_grp1/pages/settings/models/reminder_page.dart';
import 'package:projet_sigh_grp1/pages/settings/models/help_page.dart';
import 'package:projet_sigh_grp1/pages/settings/models/conditions_page.dart';
import 'package:projet_sigh_grp1/pages/settings/models/reminder_page.dart';
import 'conditions_page.dart';
import 'conditions_page.dart';
import '../components/settings_card.dart';

import '../../Rappel/rappel_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // ton HeaderWidget gère déjà sa hauteur/forme
        child: LayoutBuilder(
          builder: (context, constraints) {
            double padding = constraints.maxWidth * 0.04;
            double spacing = constraints.maxHeight * 0.02;
            double cardHeight = constraints.maxHeight * 0.10;

            return SingleChildScrollView(
              child: Column(
                children: [
                  HeaderWidget(
                    title: 'Paramètres',
                    isHomePage: false,
                    isCollapsed: false,
                    navigationContext: context,
                  ),

                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.02),

                        SettingsCard(
                          title: 'Gérer les notifications et rappels',
                          backgroundColor: Colors.white,
                          onTap: () => _handleNotifications(context),
                          height: cardHeight,
                        ),
                        SizedBox(height: spacing),

                        SettingsCard(
                          title: "Conditions d'utilisation",
                          backgroundColor: Colors.white,
                          onTap: () => _handleTerms(context),
                          height: cardHeight,
                        ),
                        SizedBox(height: spacing),

                        SettingsCard(
                          title: 'Aide',
                          backgroundColor: Colors.white,
                          onTap: () => _handleHelp(context),
                          height: cardHeight,
                        ),

                        SizedBox(height: spacing),
                        SettingsCard(
                          title: 'Confidentialité & Données',
                          backgroundColor: Colors.white,
                          onTap: () => _handlePrivacy(context),
                          height: cardHeight,
                        ),

                        SizedBox(height: constraints.maxHeight * 0.10),
                        Image.asset(
                          'assets/images/logo_sigh.webp',
                          height: constraints.maxHeight * 0.10,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RappelPage()),
    );
  }

  void _handleReminders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReminderPage()),
    );
  }

  void _handleTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConditionsPage()),
    );
  }

  void _handleHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpPage()),
    );
  }

  void _handlePrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPage()),
    );
  }
}
