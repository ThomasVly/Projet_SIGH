import '../models/content_model.dart';
import '../services/content_service.dart';

/// Données factices pour la table Content
class ContentFakeData {
  /// Retourne une liste de contenus factices
  static List<ContentModel> getFakeContents() {
    return [
      // Article À LA UNE - Utilise le PDF local pour les tests
      ContentModel(
        title: '5 gestes simples pour économiser 20% sur votre facture',
        tags: 'économie, éco-gestes, électricité',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 5,
        notation: 5,
        isFeatured: true,
        pdfUrl: 'assets/files/PDF_example.pdf',
      ),

      // Fiches info - Chauffage
      ContentModel(
        title: 'Le chauffage dans les pièces',
        tags: 'température, chauffage, confort',
        type: 'fiche',
        category: 'Chauffage',
        readingTime: 3,
        notation: 5,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=7091',
      ),

      ContentModel(
        title: 'Optimiser son chauffage électrique',
        tags: 'chauffage, électricité, optimisation',
        type: 'fiche',
        category: 'Chauffage',
        readingTime: 6,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2142',
      ),

      ContentModel(
        title: 'Isolation thermique : les bases',
        tags: 'isolation, chauffage, rénovation',
        type: 'fiche',
        category: 'Chauffage',
        readingTime: 8,
        notation: 5,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=4905',
      ),

      // Fiches info - Électricité
      ContentModel(
        title: 'Comprendre sa facture d\'électricité',
        tags: 'facture, électricité, tarifs',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 4,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2958',
      ),

      ContentModel(
        title: 'Les appareils en veille : combien ça coûte ?',
        tags: 'veille, économie, électricité',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 3,
        notation: 5,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=826',
      ),

      ContentModel(
        title: 'Éclairage LED : guide complet',
        tags: 'éclairage, LED, économie',
        type: 'fiche',
        category: 'Électricité',
        readingTime: 5,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2146',
      ),

      // Fiches info - Électroménager
      ContentModel(
        title: 'Bien choisir son électroménager',
        tags: 'électroménager, étiquette énergie, achat',
        type: 'fiche',
        category: 'Électroménager',
        readingTime: 7,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=827',
      ),

      ContentModel(
        title: 'Entretenir son réfrigérateur',
        tags: 'réfrigérateur, entretien, économie',
        type: 'fiche',
        category: 'Électroménager',
        readingTime: 3,
        notation: 3,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2144',
      ),

      // Tutoriels - Chauffage
      ContentModel(
        title: 'Installer un thermostat programmable',
        tags: 'thermostat, installation, chauffage',
        type: 'tutorial',
        category: 'Chauffage',
        readingTime: 15,
        notation: 5,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2145',
      ),

      ContentModel(
        title: 'Purger vos radiateurs',
        tags: 'radiateur, entretien, chauffage',
        type: 'tutorial',
        category: 'Chauffage',
        readingTime: 10,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2141',
      ),

      // Tutoriels - Électricité
      ContentModel(
        title: 'Réduire la consommation de votre box internet',
        tags: 'box, internet, électricité',
        type: 'tutorial',
        category: 'Électricité',
        readingTime: 5,
        notation: 3,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=826',
      ),

      ContentModel(
        title: 'Installer des multiprises intelligentes',
        tags: 'multiprise, veille, électricité',
        type: 'tutorial',
        category: 'Électricité',
        readingTime: 8,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2959',
      ),

      // Tutoriels - Lavage
      ContentModel(
        title: 'Optimiser l\'utilisation de votre lave-linge',
        tags: 'lave-linge, lavage, économie',
        type: 'tutorial',
        category: 'Lavage',
        readingTime: 6,
        notation: 4,
        pdfUrl: 'https://librairie.ademe.fr/index.php?controller=attachment&id_attachment=2143',
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
