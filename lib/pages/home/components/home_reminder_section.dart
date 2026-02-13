import 'dart:math';
import 'package:flutter/material.dart';
import '../../Rappel/models/reminder.dart';
import '../../Rappel/rappel_page.dart';

class HomeReminderSection extends StatefulWidget {
  final List<Reminder> reminders; // Liste requise
  final VoidCallback? onSettingsTap;

  const HomeReminderSection({
    super.key,
    required this.reminders,
    this.onSettingsTap,
  });

  @override
  State<HomeReminderSection> createState() => _HomeReminderSectionState();
}

class _HomeReminderSectionState extends State<HomeReminderSection> {
  late bool _showConfigurationPromo;

  @override
  void initState() {
    super.initState();
    // LOGIQUE 1 FOIS SUR 2 :
    // Si la liste est vide, on force l'affichage de la promo.
    _showConfigurationPromo = widget.reminders.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes Rappels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264777),
              ),
            ),
            // Le bouton "+" n'apparaît que si on affiche la liste
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

        // CONTENU CONDITIONNEL
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showConfigurationPromo
              ? _buildConfigurationCard(context)
              : _buildRemindersList(),
        ),
      ],
    );
  }

  // --- CAS 1 : La carte Promo ---
  Widget _buildConfigurationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
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
                  child: const Icon(Icons.notification_add, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activez vos rappels !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Ne manquez plus jamais d\'éteindre ou d\'aérer.', style: TextStyle(color: Colors.white, fontSize: 13)),
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

  // --- CAS 2 : La liste réelle ---
  Widget _buildRemindersList() {
    // On prend maximum 3 rappels pour l'accueil
    final displayList = widget.reminders.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];

        // Formatage de l'heure depuis scheduledTime
        final String formattedTime = item.scheduledTime != null
            ? "${item.scheduledTime!.hour.toString().padLeft(2, '0')}:${item.scheduledTime!.minute.toString().padLeft(2, '0')}"
            : "--:--";

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
              // Heure formatée
              Text(
                formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF264777),
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 2, height: 24, color: Colors.grey[300]),
              const SizedBox(width: 16),
              // Titre
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Icône venant de l'extension du modèle
              Text(
                item.type.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToSettings(BuildContext context) {
    if (widget.onSettingsTap != null) {
      widget.onSettingsTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RappelPage()),
      );
    }
  }
}