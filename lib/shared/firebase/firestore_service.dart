import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _conseilCollection = _firestore.collection('conseil');


  /// Récupère tous les conseils (documents) depuis Firestore
  /// Retour: liste de maps contenant au minimum { id: <docId>, ...data }
  static Future<List<Map<String, dynamic>>> getConseils() async {
    try {
      final querySnapshot = await _conseilCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...(data is Map<String, dynamic> ? data : <String, dynamic>{}),
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching conseils: $e');
      rethrow;
    }
  }

  // TEMPORARY TEST DATA (schema aligné avec Content)
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
}
