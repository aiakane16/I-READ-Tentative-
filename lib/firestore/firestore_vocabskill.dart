import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreVocabSkill {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getModules() async {
    var snapshot =
        await _firestore.collection('fields').doc('Vocabulary Skills').get();
    return List<Map<String, dynamic>>.from(snapshot.data()?['modules'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getQuestions(String moduleId) async {
    var snapshot = await _firestore
        .collection('fields')
        .doc('Vocabulary Skills')
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
