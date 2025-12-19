 import 'package:flutter/material.dart';
 import '../models/badge.dart' as model;
 
 class BadgeService {
   const BadgeService();
 
   /// Retourne la liste des badges avec
   /// - description courte
   /// - condition textuelle pour l'obtenir
   /// - progression actuelle.
   List<model.Badge> fetchBadges() {
     return const [
       model.Badge(
         id: 'premiers_pas',
         title: 'Premiers pas',
         description: 'Votre tout premier badge sur SIGH.',
         condition: 'Compléter une première action dans l’application.',
         progressLabel: '1/1',
         progress: 1,
         status: model.BadgeStatus.unlocked,
         icon: Icons.directions_walk,
         color: Color(0xFF6E3CE3),
       ),
       model.Badge(
         id: 'econome',
         title: 'Économe',
         description: 'Réduisez votre consommation d’énergie.',
         condition: 'Atteindre 50 kWh d’économie.',
         progressLabel: '0/50 kWh',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.lightbulb_outline,
         color: Color(0xFF82C341),
       ),
       model.Badge(
         id: 'expert_quiz',
         title: 'Expert Quiz',
         description: 'Testez vos connaissances avec les quiz énergie.',
         condition: 'Terminer 5 quiz.',
         progressLabel: '0/5 quiz',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.track_changes,
         color: Color(0xFF4AA3FF),
       ),
       model.Badge(
         id: 'champion',
         title: 'Champion',
         description: 'Relèvez les défis proposés chaque semaine.',
         condition: 'Réussir 3 défis.',
         progressLabel: '0/3 défis',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.emoji_events_outlined,
         color: Color(0xFFF5A524),
       ),
       model.Badge(
         id: 'lecteur',
         title: 'Lecteur',
         description: 'Informez-vous avec nos articles.',
         condition: 'Lire 10 articles.',
         progressLabel: '0/10 articles',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.menu_book_outlined,
         color: Color(0xFF4AA3FF),
       ),
       model.Badge(
         id: 'assidu',
         title: 'Assidu',
         description: 'Revenez régulièrement dans l’application.',
         condition: 'Se connecter 7 jours d’affilée.',
         progressLabel: '0/7 jours',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.local_fire_department_outlined,
         color: Color(0xFFF65D5D),
       ),
       model.Badge(
         id: 'eco_expert',
         title: 'Éco-expert',
         description: 'Devenez un expert des économies d’énergie.',
         condition: 'Cumuler 200 kWh d’économie.',
         progressLabel: '0/200 kWh',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.eco_outlined,
         color: Color(0xFF82C341),
       ),
       model.Badge(
         id: 'perfectionniste',
         title: 'Perfectionniste',
         description: 'Vous avez débloqué tous les autres badges.',
         condition: 'Débloquer l’ensemble des badges.',
         progressLabel: '0/7 badges',
         progress: 0,
         status: model.BadgeStatus.locked,
         icon: Icons.star_outline,
         color: Color(0xFFB0B6C0),
       ),
     ];
   }
 }
