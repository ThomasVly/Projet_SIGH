# 🌿 SIGH-Energie & Moi - Assistant de Transition Énergétique

SIGH-Energie & Moi est une application mobile développée avec **Flutter** conçue pour aider les particuliers à reprendre le contrôle de leur consommation d'énergie domestique. L'application combine le suivi de données, la gestion intelligente des habitudes et la gamification pour encourager des comportements éco-responsables.

## ✨ Fonctionnalités Principales

* **Tableau de Bord Dynamique :** Visualisation de la consommation électrique via des graphiques interactifs (kWh et coûts financiers) avec un code couleur adaptatif (vert à rouge) selon l'intensité.
* **Gestion des Rappels "Heures Creuses" :** Système de notifications intelligent qui priorise les alertes liées aux changements tarifaires (Heures Creuses/Pleines) pour optimiser l'utilisation des appareils énergivores.
* **Inventaire des Équipements :** Gestion détaillée des appareils par pièce (Cuisine, Salon, etc.) permettant d'identifier les principaux postes de consommation de la maison.
* **Défis Écologiques (Gamification) :** Participation à des défis mensuels synchronisés via le cloud pour gagner de l'expérience (XP) et débloquer des badges exclusifs.
* **Contenu Éducatif :** Accès à une bibliothèque de conseils, d'articles et de vidéos YouTube intégrées pour adopter les bons gestes au quotidien.
* **Système de Progression :** Profil utilisateur complet incluant un niveau d'expérience, une sélection d'avatars et une galerie de badges débloqués.


## 🚀 Installation et Démarrage

### Prérequis
* **Flutter SDK** : Assurez-vous d'avoir la dernière version stable installée.
* **Dart SDK** : Inclus avec Flutter.
* **Environnement** : Un émulateur (Android/iOS) ou un appareil physique connecté.

### Guide étape par étape

1.  **Récupération du projet**
    ```bash
    git clone [https://github.com/ThomasVly/Projet_SIGH.git](https://github.com/ThomasVly/Projet_SIGH.git)
    ```

2.  **Installation des dépendances**
    Téléchargez les paquets requis (fl_chart, firebase_core, provider, sqflite, etc.) :
    ```bash
    flutter pub get
    ```

3. **Lancement de l'application**
    Lancez l'application en mode debug :
    ```bash
    flutter run
    ```

### Dépannage courant
* **Erreur de base de données** : Si vous rencontrez des soucis avec SQLite, essayez de désinstaller l'application de l'émulateur pour forcer la recréation de la base de données locale via `DB-Creator`.
* **Assets manquants** : Si les images ne s'affichent pas, vérifiez que votre fichier `pubspec.yaml` inclut bien les chemins vers `assets/images/`.