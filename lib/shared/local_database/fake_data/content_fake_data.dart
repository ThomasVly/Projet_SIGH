import '../models/content_model.dart';
import '../services/content_service.dart';

/// Données factices pour la table Content
class ContentFakeData {
  /// Retourne une liste de contenus factices
  static List<ContentModel> getFakeContents() {
    return [
      // Articles
      ContentModel(
        title: 'Comment réduire sa consommation électrique',
        tags: 'électricité, économie, éco-gestes',
        type: 'article',
        notation: 5,
      ),
      ContentModel(
        title: 'Les énergies renouvelables en France',
        tags: 'énergie, renouvelable, environnement',
        type: 'article',
        notation: 4,
      ),
      ContentModel(
        title: '10 astuces pour économiser l\'eau',
        tags: 'eau, économie, astuces',
        type: 'article',
        notation: 5,
      ),
      ContentModel(
        title: 'Comprendre sa facture d\'électricité',
        tags: 'électricité, facture, comprendre',
        type: 'article',
        notation: 4,
      ),
      ContentModel(
        title: 'Le chauffage électrique : avantages et inconvénients',
        tags: 'chauffage, électricité, comparatif',
        type: 'article',
        notation: 3,
      ),

      // Fiches info
      ContentModel(
        title: 'Comment vidanger son radiateur ?',
        tags: 'radiateur, entretien, chauffage',
        type: 'fiche',
        notation: 5,
      ),
      ContentModel(
        title: 'Entretenir son chauffe-eau',
        tags: 'chauffe-eau, entretien, eau',
        type: 'fiche',
        notation: 4,
      ),
      ContentModel(
        title: 'Isolation thermique : les bases',
        tags: 'isolation, thermique, économie',
        type: 'fiche',
        notation: 5,
      ),
      ContentModel(
        title: 'Les classes énergétiques des appareils',
        tags: 'électroménager, classe énergétique, consommation',
        type: 'fiche',
        notation: 4,
      ),
      ContentModel(
        title: 'Installer un thermostat programmable',
        tags: 'thermostat, installation, chauffage',
        type: 'fiche',
        notation: 5,
      ),
      ContentModel(
        title: 'LED vs Ampoules classiques',
        tags: 'éclairage, LED, économie',
        type: 'fiche',
        notation: 4,
      ),
      ContentModel(
        title: 'Le compteur Linky expliqué',
        tags: 'compteur, Linky, électricité',
        type: 'fiche',
        notation: 3,
      ),

      // Tutoriels
      ContentModel(
        title: 'Installer des panneaux solaires',
        tags: 'solaire, installation, énergie',
        type: 'tutorial',
        notation: 5,
      ),
      ContentModel(
        title: 'Programmer son chauffage pour économiser',
        tags: 'chauffage, programmation, économie',
        type: 'tutorial',
        notation: 4,
      ),
      ContentModel(
        title: 'Détecter les appareils énergivores',
        tags: 'consommation, détection, économie',
        type: 'tutorial',
        notation: 5,
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
