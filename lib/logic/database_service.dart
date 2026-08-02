import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Update User Profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Upload Profile Picture
  Future<String> uploadProfilePicture(String uid, File image) async {
    Reference ref = _storage.ref().child('profile_pics').child('$uid.jpg');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
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

  // Delete History Item
  Future<void> deleteHistoryItem(String uid, String docId) async {
    await _db.collection('users').doc(uid).collection('history').doc(docId).delete();
  }

  // Save Favorite
  Future<void> saveFavorite(String uid, Map<String, dynamic> problemData) async {
    // Prevent duplicates by using a hash or just checking if exists, but for simplicity:
    await _db.collection('users').doc(uid).collection('favorites').add({
      ...problemData,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Favorites
  Stream<QuerySnapshot> getFavorites(String uid) {
    return _db.collection('users').doc(uid).collection('favorites')
        .orderBy('savedAt', descending: true).snapshots();
  }

  // Delete Favorite
  Future<void> deleteFavorite(String uid, String docId) async {
    await _db.collection('users').doc(uid).collection('favorites').doc(docId).delete();
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
