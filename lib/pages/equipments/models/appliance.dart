import 'package:flutter/material.dart';
import 'equipment.dart';

class Appliance {
  final int id;
  final String name;
  final IconData icon;
  final double consumptionPerHour;
  final double usageHoursPerDay;
  final int usageDaysPerWeek;

  const Appliance({
    required this.id,
    required this.name,
    required this.icon,
    required this.consumptionPerHour,
    this.usageHoursPerDay = 1.0,
    this.usageDaysPerWeek = 7,
  });

  static const double defaultPricePerKwh = 0.2;

  double get monthlyConsumptionKwh {
    return consumptionPerHour * usageHoursPerDay * usageDaysPerWeek * 4.33;
  }

  double get monthlyCost {
    return monthlyConsumptionKwh * defaultPricePerKwh;
  }

  static final List<Appliance> predefinedAppliances = [
    // ========== CUISINE ==========
    Appliance(
      id: 1,
      name: 'Cafetière',
      icon: Icons.coffee,
      consumptionPerHour: 0.8,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 2,
      name: 'Bouilloire',
      icon: Icons.power,
      consumptionPerHour: 2.0,
      usageHoursPerDay: 0.25,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 3,
      name: 'Four',
      icon: Icons.power,
      consumptionPerHour: 2.3,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 4,
    ),
    Appliance(
      id: 4,
      name: 'Plaque de cuisson',
      icon: Icons.power,
      consumptionPerHour: 2.0,
      usageHoursPerDay: 1.5,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 5,
      name: 'Micro-ondes',
      icon: Icons.microwave,
      consumptionPerHour: 1.2,
      usageHoursPerDay: 0.33,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 6,
      name: 'Réfrigérateur',
      icon: Icons.kitchen,
      consumptionPerHour: 0.15,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 7,
      name: 'Congélateur',
      icon: Icons.ac_unit,
      consumptionPerHour: 0.25,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 8,
      name: 'Lave-vaisselle',
      icon: Icons.power,
      consumptionPerHour: 1.2,
      usageHoursPerDay: 1.5,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 9,
      name: 'Hotte aspirante',
      icon: Icons.air,
      consumptionPerHour: 0.2,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 10,
      name: 'Mixeur',
      icon: Icons.blender,
      consumptionPerHour: 0.3,
      usageHoursPerDay: 0.1,
      usageDaysPerWeek: 3,
    ),
    Appliance(
      id: 11,
      name: 'Robot multifonction',
      icon: Icons.food_bank,
      consumptionPerHour: 0.5,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 2,
    ),
    Appliance(
      id: 12,
      name: 'Grille-pain',
      icon: Icons.power,
      consumptionPerHour: 1.1,
      usageHoursPerDay: 0.1,
      usageDaysPerWeek: 5,
    ),

    // ========== LAVAGE ==========
    Appliance(
      id: 15,
      name: 'Machine à laver',
      icon: Icons.local_laundry_service,
      consumptionPerHour: 0.9,
      usageHoursPerDay: 1.5,
      usageDaysPerWeek: 4,
    ),
    Appliance(
      id: 16,
      name: 'Sèche-linge',
      icon: Icons.dry_cleaning,
      consumptionPerHour: 2.5,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 3,
    ),
    Appliance(
      id: 17,
      name: 'Fer à repasser',
      icon: Icons.iron,
      consumptionPerHour: 1.2,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 2,
    ),

    // ========== CLIMATISATION ==========
    Appliance(
      id: 19,
      name: 'Climatiseur',
      icon: Icons.ac_unit,
      consumptionPerHour: 1.5,
      usageHoursPerDay: 8.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 20,
      name: 'Ventilateur',
      icon: Icons.air,
      consumptionPerHour: 0.05,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 21,
      name: 'Chauffage d\'appoint',
      icon: Icons.heat_pump,
      consumptionPerHour: 1.5,
      usageHoursPerDay: 4.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 22,
      name: 'Radiateur',
      icon: Icons.heat_pump,
      consumptionPerHour: 1.0,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 23,
      name: 'Pompe à chaleur',
      icon: Icons.thermostat,
      consumptionPerHour: 0.8,
      usageHoursPerDay: 8.0,
      usageDaysPerWeek: 7,
    ),

    // ========== ÉCLAIRAGE ==========
    Appliance(
      id: 24,
      name: 'Ampoule LED',
      icon: Icons.lightbulb,
      consumptionPerHour: 0.01,
      usageHoursPerDay: 5.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 25,
      name: 'Ampoule halogène',
      icon: Icons.lightbulb,
      consumptionPerHour: 0.04,
      usageHoursPerDay: 4.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 26,
      name: 'Lampe de bureau',
      icon: Icons.power,
      consumptionPerHour: 0.03,
      usageHoursPerDay: 3.0,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 27,
      name: 'Guirlande lumineuse',
      icon: Icons.light,
      consumptionPerHour: 0.02,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 7,
    ),

    // ========== ÉLECTRONIQUE ==========
    Appliance(
      id: 28,
      name: 'Télévision LED',
      icon: Icons.tv,
      consumptionPerHour: 0.1,
      usageHoursPerDay: 3.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 29,
      name: 'Ordinateur fixe',
      icon: Icons.computer,
      consumptionPerHour: 0.2,
      usageHoursPerDay: 4.0,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 30,
      name: 'Ordinateur portable',
      icon: Icons.laptop,
      consumptionPerHour: 0.05,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 31,
      name: 'Écran LCD',
      icon: Icons.desktop_windows,
      consumptionPerHour: 0.03,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 32,
      name: 'Console de jeu',
      icon: Icons.videogame_asset,
      consumptionPerHour: 0.15,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 33,
      name: 'Routeur Wi-Fi',
      icon: Icons.router,
      consumptionPerHour: 0.01,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 34,
      name: 'Box Internet',
      icon: Icons.cable,
      consumptionPerHour: 0.015,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 35,
      name: 'Haut-parleurs',
      icon: Icons.speaker,
      consumptionPerHour: 0.02,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 36,
      name: 'Chargeur smartphone',
      icon: Icons.battery_charging_full,
      consumptionPerHour: 0.005,
      usageHoursPerDay: 3.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 37,
      name: 'Tablette',
      icon: Icons.tablet,
      consumptionPerHour: 0.008,
      usageHoursPerDay: 4.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 38,
      name: 'Enceinte Bluetooth',
      icon: Icons.speaker_group,
      consumptionPerHour: 0.01,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 5,
    ),

    // ========== SDB ==========
    Appliance(
      id: 39,
      name: 'Sèche-cheveux',
      icon: Icons.power,
      consumptionPerHour: 1.5,
      usageHoursPerDay: 0.15,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 40,
      name: 'Rasoir',
      icon: Icons.cut,
      consumptionPerHour: 0.02,
      usageHoursPerDay: 0.08,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 41,
      name: 'Brosse à dents',
      icon: Icons.clean_hands,
      consumptionPerHour: 0.002,
      usageHoursPerDay: 0.05,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 42,
      name: 'Chauffe-serviettes',
      icon: Icons.hot_tub,
      consumptionPerHour: 0.6,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 7,
    ),

    // ========== NETTOYAGE ==========
    Appliance(
      id: 44,
      name: 'Aspirateur',
      icon: Icons.cleaning_services,
      consumptionPerHour: 1.2,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 2,
    ),
    Appliance(
      id: 45,
      name: 'Robot aspirateur',
      icon: Icons.smart_toy,
      consumptionPerHour: 0.03,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 3,
    ),
    Appliance(
      id: 46,
      name: 'Lave-vitres',
      icon: Icons.window,
      consumptionPerHour: 0.1,
      usageHoursPerDay: 0.25,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 47,
      name: 'Nettoyeur vapeur',
      icon: Icons.clean_hands,
      consumptionPerHour: 1.5,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 1,
    ),

    // ========== CUISINE SPÉCIALISÉE ==========
    Appliance(
      id: 48,
      name: 'Friteuse',
      icon: Icons.fastfood,
      consumptionPerHour: 1.8,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 2,
    ),
    Appliance(
      id: 49,
      name: 'Raclette',
      icon: Icons.restaurant,
      consumptionPerHour: 1.2,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 50,
      name: 'Gaufrier',
      icon: Icons.cake,
      consumptionPerHour: 0.9,
      usageHoursPerDay: 0.25,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 51,
      name: 'Yaourtière',
      icon: Icons.breakfast_dining,
      consumptionPerHour: 0.1,
      usageHoursPerDay: 8.0,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 52,
      name: 'Sorbetière',
      icon: Icons.icecream,
      consumptionPerHour: 0.15,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 53,
      name: 'Mijoteuse',
      icon: Icons.soup_kitchen,
      consumptionPerHour: 0.2,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 54,
      name: 'Fondu',
      icon: Icons.restaurant,
      consumptionPerHour: 0.8,
      usageHoursPerDay: 1.5,
      usageDaysPerWeek: 1,
    ),

    // ========== BUREAU ==========
    Appliance(
      id: 55,
      name: 'Imprimante',
      icon: Icons.print,
      consumptionPerHour: 0.05,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 3,
    ),
    Appliance(
      id: 56,
      name: 'Scanner',
      icon: Icons.scanner,
      consumptionPerHour: 0.03,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 2,
    ),
    Appliance(
      id: 57,
      name: 'Lampe de chantier',
      icon: Icons.highlight,
      consumptionPerHour: 0.3,
      usageHoursPerDay: 4.0,
      usageDaysPerWeek: 5,
    ),
    Appliance(
      id: 58,
      name: 'Perforateur',
      icon: Icons.handyman,
      consumptionPerHour: 0.8,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 59,
      name: 'Scie',
      icon: Icons.carpenter,
      consumptionPerHour: 1.2,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 1,
    ),
    Appliance(
      id: 60,
      name: 'Ponceuse',
      icon: Icons.construction,
      consumptionPerHour: 0.4,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 1,
    ),

    // ========== LOISIRS ==========
    Appliance(
      id: 61,
      name: 'Aquarium',
      icon: Icons.waves,
      consumptionPerHour: 0.05,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 62,
      name: 'Terrarium',
      icon: Icons.thermostat,
      consumptionPerHour: 0.1,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 63,
      name: 'Tapis roulant',
      icon: Icons.directions_run,
      consumptionPerHour: 0.7,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 4,
    ),
    Appliance(
      id: 64,
      name: 'Vélo d\'appartement',
      icon: Icons.directions_bike,
      consumptionPerHour: 0.02,
      usageHoursPerDay: 0.5,
      usageDaysPerWeek: 4,
    ),
    Appliance(
      id: 65,
      name: 'Projecteur vidéo',
      icon: Icons.video_camera_back,
      consumptionPerHour: 0.25,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 2,
    ),
    Appliance(
      id: 66,
      name: 'Machine à coudre',
      icon: Icons.power,
      consumptionPerHour: 0.1,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 2,
    ),

    // ========== SÉCURITÉ ==========
    Appliance(
      id: 67,
      name: 'Alarme maison',
      icon: Icons.security,
      consumptionPerHour: 0.005,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 68,
      name: 'Caméra surveillance',
      icon: Icons.videocam,
      consumptionPerHour: 0.01,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 69,
      name: 'Interphone vidéo',
      icon: Icons.doorbell,
      consumptionPerHour: 0.008,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 70,
      name: 'Portail électrique',
      icon: Icons.garage,
      consumptionPerHour: 0.3,
      usageHoursPerDay: 0.05,
      usageDaysPerWeek: 7,
    ),

    // ========== DIVERS ==========
    Appliance(
      id: 71,
      name: 'Pompe à eau',
      icon: Icons.water,
      consumptionPerHour: 0.5,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 72,
      name: 'Chauffe-eau',
      icon: Icons.water_damage,
      consumptionPerHour: 1.5,
      usageHoursPerDay: 2.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 73,
      name: 'Ventilateur de plafond',
      icon: Icons.ac_unit,
      consumptionPerHour: 0.07,
      usageHoursPerDay: 8.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 74,
      name: 'Humidificateur',
      icon: Icons.water_drop,
      consumptionPerHour: 0.05,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 75,
      name: 'Déshumidificateur',
      icon: Icons.power,
      consumptionPerHour: 0.3,
      usageHoursPerDay: 6.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 76,
      name: 'Purificateur d\'air',
      icon: Icons.air,
      consumptionPerHour: 0.05,
      usageHoursPerDay: 8.0,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 77,
      name: 'Enrouleur de câble',
      icon: Icons.cable,
      consumptionPerHour: 0.001,
      usageHoursPerDay: 1.0,
      usageDaysPerWeek: 3,
    ),
    Appliance(
      id: 78,
      name: 'Distributeur de croquettes',
      icon: Icons.pets,
      consumptionPerHour: 0.002,
      usageHoursPerDay: 0.1,
      usageDaysPerWeek: 7,
    ),
    Appliance(
      id: 79,
      name: 'Fontaine à eau pour animaux',
      icon: Icons.water,
      consumptionPerHour: 0.003,
      usageHoursPerDay: 24,
      usageDaysPerWeek: 7,
    ),
  ];

  // Recherche par nom
  static List<Appliance> search(String query) {
    if (query.isEmpty) return predefinedAppliances;
    
    final lowerQuery = query.toLowerCase();
    return predefinedAppliances
        .where((appliance) =>
            appliance.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

extension ApplianceExtension on Appliance {
  Equipment toEquipment(String roomName) {
    return Equipment(
      name: name,
      roomName: roomName,
      consumptionPerHour: consumptionPerHour,
      usageHoursPerDay: usageHoursPerDay,
      usageDaysPerWeek: usageDaysPerWeek,
      pricePerKwh: Appliance.defaultPricePerKwh,
      icon: icon,
    );
  }
}