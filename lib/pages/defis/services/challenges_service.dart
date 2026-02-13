import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _challengesCollection =
      _firestore.collection('challenges'); // 🔁 adapte le nom si besoin

  /// Récupère les défis bruts depuis Firestore
  static Future<List<Map<String, dynamic>>> getChallengesRaw() async {
    try {
      final querySnapshot = await _challengesCollection
          // 🔁 si tu n'as pas de champ 'order', enlève la ligne suivante
          .orderBy('order', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching challenges: $e');
      rethrow;
    }
  }
}
