import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _conseilCollection = _firestore.collection('conseil');
  static final CollectionReference _quizCollection = _firestore.collection('quizzes'); // 'quizzes' avec un 's'


  // TEMPORARY TEST DATA
  static Future<String> uploadConseilData() async {
    try {
      final docRef = await _conseilCollection.add({
        'title': 'how to become famous',
        'description': 'how to become famous',
        'detail': 'https://www.wikihow.com/Become-Famous',
        'timestamp': FieldValue.serverTimestamp(),
        'pdf': true,
        'tags': {'rich','people'},
        'type': 'famous',
      });

      print('✅ Test data uploaded successfully! Document ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error uploading test data: $e');
      rethrow;
    }
  }


  static Future<List<Map<String, dynamic>>> getConseils() async {
    return getCollectionData(_conseilCollection.id);
  }

  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    return getCollectionData(_quizCollection.id);
  }

  static Future<List<Map<String, dynamic>>> getCollectionData(String collectionName) async {
    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('❌ Error fetching collection data: $e');
      rethrow;
    }
  }

  //  SECTION CHALLENGES (DÉFIS)
 static final CollectionReference _challengesCollection =
      _firestore.collection('challenges');

  /// Récupère les défis de la collection "challenges"
  ///
  /// Retour : List<Map> avec au minimum :
  ///  - id (String)
  ///  - title (String)
  ///  - description (String)
  ///  - reminder (String)
  ///  - reward (int)
  ///  - month (String "YYYY-MM")
  static Future<List<Map<String, dynamic>>> getChallenges() async {
    try {
      final querySnapshot = await _challengesCollection
          .orderBy('month', descending: true) // du plus récent au plus ancien
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('❌ Error fetching challenges: $e');
      rethrow;
    }
  }
}

