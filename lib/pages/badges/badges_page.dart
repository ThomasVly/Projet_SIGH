import 'package:flutter/material.dart';

import 'components/badges_card.dart';
import 'services/badge_service.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = const BadgeService().fetchBadges();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BadgesCard(badges: badges),
          ],
        ),
      ),
    );
  }
}
