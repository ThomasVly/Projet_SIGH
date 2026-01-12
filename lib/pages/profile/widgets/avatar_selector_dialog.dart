import 'package:flutter/material.dart';

class AvatarSelectorDialog extends StatelessWidget {
  final String currentAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelectorDialog({
    super.key,
    required this.currentAvatar,
    required this.onAvatarSelected,
  });

  // Liste d'avatars sur le thème de l'énergie (12 avatars)
  static const List<Map<String, String>> energyAvatars = [
    {'emoji': '⚡', 'name': 'Éclair'},
    {'emoji': '🔋', 'name': 'Batterie'},
    {'emoji': '💡', 'name': 'Ampoule'},
    {'emoji': '☀️', 'name': 'Soleil'},
    {'emoji': '🌊', 'name': 'Eau'},
    {'emoji': '🔥', 'name': 'Feu'},
    {'emoji': '💨', 'name': 'Vent'},
    {'emoji': '♻️', 'name': 'Recyclage'},
    {'emoji': '🌱', 'name': 'Plante'},
    {'emoji': '🌍', 'name': 'Terre'},
    {'emoji': '🚀', 'name': 'Fusée'},
    {'emoji': '⭐', 'name': 'Étoile'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: screenHeight * 0.7,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Choisis ton avatar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0056A6),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Text(
                  'Thème : Énergie & Environnement',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                // Grille d'avatars (3x4 = 12 avatars)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: energyAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = energyAvatars[index];
                    final emoji = avatar['emoji']!;
                    final name = avatar['name']!;
                    final isSelected = emoji == currentAvatar;

                    return GestureDetector(
                      onTap: () {
                        onAvatarSelected(emoji);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF0056A6)
                                  : const Color(0xFF4A90E2),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00FF00)
                                    : Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: const Color(0xFF00FF00).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Message info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0056A6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF0056A6),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ton avatar représente ton engagement pour l\'énergie durable !',
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF0056A6).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
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

