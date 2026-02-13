import 'package:flutter/material.dart';
// ✅ Ajustez selon votre structure de projet
import '../../Rappel/rappel_page.dart';
import '../../Rappel/models/reminder.dart';

/// VERSION PRIORITÉ : Affiche les heures creuses/pleines en premier, puis les autres rappels
/// Maximum 3 rappels au total
class HomeReminderSection extends StatefulWidget {
  final List<Reminder> reminders;
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
  @override
  Widget build(BuildContext context) {
    // ✅ TRIER : heures creuses/pleines en premier
    final sortedReminders = [...widget.reminders];
    sortedReminders.sort((a, b) {
      final aIsOffPeak = a.type == ReminderType.offPeakHours || 
                         a.type == ReminderType.peakHours;
      final bIsOffPeak = b.type == ReminderType.offPeakHours || 
                         b.type == ReminderType.peakHours;
      
      // Les heures creuses/pleines en premier
      if (aIsOffPeak && !bIsOffPeak) return -1;
      if (!aIsOffPeak && bIsOffPeak) return 1;
      
      // Sinon, trier par heure
      if (a.scheduledTime == null) return 1;
      if (b.scheduledTime == null) return -1;
      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });

    // Prendre maximum 3 rappels
    final displayList = sortedReminders.take(3).toList();
    final bool showConfigurationPromo = displayList.isEmpty;

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
            if (!showConfigurationPromo)
              InkWell(
                onTap: () => _navigateToSettings(context),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // CONTENU CONDITIONNEL
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: showConfigurationPromo
              ? _buildConfigurationCard(context)
              : _buildRemindersList(displayList),
        ),
      ],
    );
  }

  // --- CAS 1 : La carte Promo ---
  Widget _buildConfigurationCard(BuildContext context) {
    return Container(
      key: const ValueKey('promo'),
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

  // --- CAS 2 : La liste des rappels (avec heures creuses en premier) ---
  Widget _buildRemindersList(List<Reminder> displayList) {
    return ListView.builder(
      key: const ValueKey('list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];

        // Formatage de l'heure
        final String formattedTime = item.scheduledTime != null
            ? "${item.scheduledTime!.hour.toString().padLeft(2, '0')}:${item.scheduledTime!.minute.toString().padLeft(2, '0')}"
            : "--:--";

        // Déterminer si c'est un rappel heures creuses/pleines
        final bool isOffPeakRelated = item.type == ReminderType.offPeakHours || 
                                       item.type == ReminderType.peakHours;

        // Couleur selon le type
        Color accentColor;
        if (item.type == ReminderType.offPeakHours) {
          accentColor = const Color(0xFF72BA00);
        } else if (item.type == ReminderType.peakHours) {
          accentColor = const Color(0xFFFF9966);
        } else {
          accentColor = const Color(0xFF264777);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOffPeakRelated 
                ? accentColor.withOpacity(0.3)
                : const Color(0xFFE0E0E0),
              width: isOffPeakRelated ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isOffPeakRelated 
                  ? accentColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Heure avec badge si heures creuses
              if (isOffPeakRelated)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: accentColor,
                    ),
                  ),
                )
              else
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: isOffPeakRelated ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              
              // Icône
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

  void _navigateToSettings(BuildContext context) async {
    if (widget.onSettingsTap != null) {
      widget.onSettingsTap!();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RappelPage()),
      );
    }
  }
}
