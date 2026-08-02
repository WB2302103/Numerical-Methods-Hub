import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Update User Profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Save Solved Problem
  Future<void> saveSolvedProblem({
    required String uid,
    required String method,
    required List<List<String>> matrix,
    required List<String> constantVector,
    required List<String> answer,
  }) async {
    await _db.collection('users').doc(uid).collection('history').add({
      'method': method,
      'matrix': matrix,
      'constantVector': constantVector,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get History
  Stream<QuerySnapshot> getHistory(String uid) {
    return _db.collection('users').doc(uid).collection('history')
        .orderBy('timestamp', descending: true).snapshots();
  }

  // Save Favorite
  Future<void> saveFavorite(String uid, Map<String, dynamic> problemData) async {
    await _db.collection('users').doc(uid).collection('favorites').add(problemData);
  }

  // Submit Feedback/Bug Report
  Future<void> submitReport(String type, String message, {double? rating}) async {
    await _db.collection('reports').add({
      'type': type,
      'message': message,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
