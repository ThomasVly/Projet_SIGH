import '../models/content_model.dart';
import '../services/content_service.dart';

/// Données factices pour la table Content
class ContentFakeData {
  /// Retourne une liste de contenus factices
  static List<ContentModel> getFakeContents() {
    return [
      // Article À LA UNE
      ContentModel(
        title: '5 gestes simples pour économiser 20% sur votre facture',
        tags: 'économie, éco-gestes, électricité',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 5,
        notation: 5,
        isFeatured: true,
        pdfUrl: 'https://www.ecologie.gouv.fr/sites/default/files/guide-ademe-reduire-facture-electricite.pdf',
      ),

      // Fiches info - Chauffage
      ContentModel(
        title: 'Le chauffage dans les pièces',
        tags: 'température, chauffage, confort',
        type: 'fiche',
        category: 'Chauffage',
        readingTime: 3,
        notation: 5,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/guide-pratique-chauffage.pdf',
      ),

      ContentModel(
        title: 'Optimiser son chauffage électrique',
        tags: 'chauffage, électricité, optimisation',
        type: 'fiche',
        category: 'Chauffage',
        readingTime: 6,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/chauffage-electrique-economies.pdf',
      ),

      ContentModel(
        title: 'Isolation thermique : les bases',
        tags: 'isolation, chauffage, rénovation',
        type: 'fiche',
        category: 'Chauffage',
        readingTime: 8,
        notation: 5,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/guide-isolation-thermique.pdf',
      ),

      // Fiches info - Électricité
      ContentModel(
        title: 'Comprendre sa facture d\'électricité',
        tags: 'facture, électricité, tarifs',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 4,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/comprendre-facture-electricite.pdf',
      ),

      ContentModel(
        title: 'Les appareils en veille : combien ça coûte ?',
        tags: 'veille, économie, électricité',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 3,
        notation: 5,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/appareils-veille-couts.pdf',
      ),

      ContentModel(
        title: 'Éclairage LED : guide complet',
        tags: 'éclairage, LED, économie',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 5,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/guide-eclairage-led.pdf',
      ),

      // Fiches info - Électroménager
      ContentModel(
        title: 'Bien choisir son électroménager',
        tags: 'électroménager, étiquette énergie, achat',
        type: 'fiche',
        category: 'Électroménager',
        readingTime: 7,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/guide-electromenager.pdf',
      ),

      ContentModel(
        title: 'Entretenir son réfrigérateur',
        tags: 'réfrigérateur, entretien, économie',
        type: 'fiche',
        category: 'Électroménager',
        readingTime: 3,
        notation: 3,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/entretien-refrigerateur.pdf',
      ),

      // Tutoriels - Chauffage
      ContentModel(
        title: 'Installer un thermostat programmable',
        tags: 'thermostat, installation, chauffage',
        type: 'tutorial',
        category: 'Chauffage',
        readingTime: 15,
        notation: 5,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/tuto-thermostat-programmable.pdf',
      ),

      ContentModel(
        title: 'Purger vos radiateurs',
        tags: 'radiateur, entretien, chauffage',
        type: 'tutorial',
        category: 'Chauffage',
        readingTime: 10,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/tuto-purger-radiateurs.pdf',
      ),

      // Tutoriels - Électricité
      ContentModel(
        title: 'Réduire la consommation de votre box internet',
        tags: 'box, internet, électricité',
        type: 'tutorial',
        category: 'Électricité',
        readingTime: 5,
        notation: 3,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/tuto-box-internet.pdf',
      ),

      ContentModel(
        title: 'Installer des multiprises intelligentes',
        tags: 'multiprise, veille, électricité',
        type: 'tutorial',
        category: 'Électricité',
        readingTime: 8,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/tuto-multiprises-intelligentes.pdf',
      ),

      // Tutoriels - Lavage
      ContentModel(
        title: 'Optimiser l\'utilisation de votre lave-linge',
        tags: 'lave-linge, lavage, économie',
        type: 'tutorial',
        category: 'Lavage',
        readingTime: 6,
        notation: 4,
        pdfUrl: 'https://www.ademe.fr/sites/default/files/assets/documents/tuto-lave-linge.pdf',
      ),
    ];
  }

  /// Insère les données factices dans la base de données
  static Future<void> populateDatabase() async {
    final ContentService contentService = ContentService();

    // Vérifie si la base contient déjà des données
    final existingContents = await contentService.getAllContents();

    if (existingContents.isEmpty) {
      print('Remplissage de la table Content avec des données factices...');
      await contentService.insertMultipleContents(getFakeContents());
      print('${getFakeContents().length} contenus insérés avec succès !');
    } else {
      print('La table Content contient déjà ${existingContents.length} éléments.');
    }
  }
}
