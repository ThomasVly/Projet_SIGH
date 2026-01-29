import 'dart:math';
import 'package:flutter/material.dart';
import 'package:projet_sigh_grp1/pages/Rappel/rappel_page.dart';
import '../../settings/models/reminder_page.dart'; // Assure-toi que l'import est bon vers ta page settings

class HomeReminderSection extends StatefulWidget {
  const HomeReminderSection({super.key});

  @override
  State<HomeReminderSection> createState() => _HomeReminderSectionState();
}

class _HomeReminderSectionState extends State<HomeReminderSection> {
  // Cette variable déterminera quel affichage montrer
  late bool _showConfigurationPromo;

  // Liste fictive de rappels pour le cas des 50% "Affichage liste"
  final List<Map<String, String>> _mockReminders = [
    {'time': '08:00', 'title': 'Aérer la chambre (10 min)', 'icon': 'window'},
    {'time': '18:30', 'title': 'Baisser le chauffage', 'icon': 'thermostat'},
  ];

  @override
  void initState() {
    super.initState();
    // LOGIQUE 50/50 :
    // Random().nextBool() renvoie true ou false aléatoirement.
    // Cette décision est prise une seule fois au chargement de la page.
    _showConfigurationPromo = Random().nextBool();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête de section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes Rappels', // Titre générique
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264777),
              ),
            ),
            // Petit bouton "+" visible seulement si on affiche la liste
            if (!_showConfigurationPromo)
              InkWell(
                onTap: () => _navigateToSettings(context),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.settings, size: 20, color: Color(0xFF405F90)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // CONTENU CONDITIONNEL (50% / 50%)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showConfigurationPromo
              ? _buildConfigurationCard(context) // Cas 1 : Promo configuration
              : _buildRemindersList(),           // Cas 2 : Liste des rappels
        ),
      ],
    );
  }

  // --- CAS 1 : La carte "Configurer ses rappels" ---
  Widget _buildConfigurationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Un dégradé Orange/Jaune pour se différencier du bleu des conseils
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5E62).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSettings(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notification_add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activez vos rappels !',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ne manquez plus jamais d\'éteindre ou d\'aérer.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CAS 2 : La liste des rappels ---
  Widget _buildRemindersList() {
    return ListView.builder(
      shrinkWrap: true, // Important dans une SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mockReminders.length,
      itemBuilder: (context, index) {
        final item = _mockReminders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Heure
              Text(
                item['time']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF264777),
                ),
              ),
              const SizedBox(width: 16),
              // Ligne verticale de séparation
              Container(width: 2, height: 24, color: Colors.grey[300]),
              const SizedBox(width: 16),
              // Titre
              Expanded(
                child: Text(
                  item['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Icone (visuel)
              Icon(
                item['icon'] == 'thermostat' ? Icons.thermostat : Icons.window,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToSettings(BuildContext context) {
    // Redirection vers ta page de configuration existante
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RappelPage()),
    );
  }
}