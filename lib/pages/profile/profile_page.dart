import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';
import '../../common-widget/navbar/navbar_widget.dart';
import '../../shared/providers/user_provider.dart';
import '../../shared/services/level_badge_service.dart';
import 'widgets/user_profile_card.dart';
import 'widgets/avatar_selector_dialog.dart';
import 'widgets/combined_badges_widget.dart';
import 'widgets/badge_unlocked_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider();

    // Callback pour afficher le badge débloqué
    _userProvider.onBadgeUnlocked = (badge) {
      _showBadgeUnlocked(badge);
    };

    // Charger le profil depuis SharedPreferences
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.initializeUser(
      id: '1',
      userName: 'Utilisateur',
      memberSince: 'Membre depuis décembre 2025',
    );
  }

  void _showAvatarSelector() {
    final currentAvatar = _userProvider.userProfile?.avatarEmoji ?? '⚡';
    showDialog(
      context: context,
      builder: (context) => AvatarSelectorDialog(
        currentAvatar: currentAvatar,
        onAvatarSelected: (emoji) {
          _userProvider.changeAvatar(emoji);
        },
      ),
    );
  }

  void _showBadgeUnlocked(LevelBadge badge) {
    // Attendre un petit délai pour que l'animation soit plus naturelle
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BadgeUnlockedDialog(badge: badge),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Profil',
              isHomePage: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Widget de profil utilisateur
                      ListenableBuilder(
                        listenable: _userProvider,
                        builder: (context, child) {
                          // Afficher le chargement
                          if (_userProvider.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final user = _userProvider.userProfile;
                          if (user == null) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('Erreur de chargement du profil'),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              UserProfileCard(
                                userName: user.userName,
                                memberSince: user.memberSince,
                                totalTests: user.totalTests,
                                quizCount: user.quizCount,
                                badges: user.badges,
                                currentLevel: user.currentLevel,
                                currentXP: user.currentXP,
                                maxXP: user.maxXP,
                                avatarEmoji: user.avatarEmoji,
                                onAvatarTap: _showAvatarSelector,
                              ),

                              // Section Mes Badges (niveau + énergie)
                              CombinedBadgesWidget(
                                currentLevel: user.currentLevel,
                                quizCount: user.quizCount,
                                challengeCount: user.challengeCount,
                                articleCount: user.articleCount,
                                loginStreak: user.loginStreak,
                                energySaved: user.energySaved,
                              ),
                            ],
                          );
                        },
                      ),

                      // Boutons de test pour simuler l'ajout d'XP
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Actions de test (pour démo)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _userProvider.onQuizCompleted(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                  ),
                                  child: const Text('Quiz (+20 XP)'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _userProvider.onChallengeCompleted(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9800),
                                  ),
                                  child: const Text('Défi (+50 XP)'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _userProvider.onTestCompleted(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                  ),
                                  child: const Text('Test (+30 XP)'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _userProvider.onArticleRead(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4AA3FF),
                                  ),
                                  child: const Text('Article lu (+2 XP)'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _userProvider.addEnergySaved(10.0),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF82C341),
                                  ),
                                  child: const Text('Énergie +10 kWh'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _userProvider.onDailyLogin(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF65D5D),
                                  ),
                                  child: const Text('Login (+5 XP)'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _userProvider.addBadge(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9C27B0),
                                  ),
                                  child: const Text('Ajouter Badge'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            NavbarWidget(
              currentIndex: 4,
              onTap: (index) {
                // Navigation vers les autres pages
                if (index != 4) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
