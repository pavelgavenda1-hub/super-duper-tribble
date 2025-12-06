import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stone_model.dart';

class StoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all stones
  Future<List<StoneModel>> getAllStones() async {
    try {
      final snapshot = await _firestore.collection('stones').get();
      return snapshot.docs
          .map((doc) => StoneModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting stones: $e');
      return [];
    }
  }

  // Get stones owned by user
  Future<List<StoneModel>> getStonesByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('stones')
          .where('ownerId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => StoneModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user stones: $e');
      return [];
    }
  }

  // Mark stone as lost
  Future<bool> markStoneAsLost(String stoneId) async {
    try {
      await _firestore.collection('stones').doc(stoneId).update({
        'isLost': true,
      });
      return true;
    } catch (e) {
      print('Error marking stone as lost: $e');
      return false;
    }
  }

  // Mark stone as found
  Future<bool> markStoneAsFound(String stoneId) async {
    try {
      await _firestore.collection('stones').doc(stoneId).update({
        'isLost': false,
      });
      return true;
    } catch (e) {
      print('Error marking stone as found: $e');
      return false;
    }
  }

  // Stream of all stones
  Stream<List<StoneModel>> stonesStream() {
    return _firestore.collection('stones').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StoneModel.fromJson(doc.data()))
          .toList();
    });
  }

  // Stream of active stones (not lost)
  Stream<List<StoneModel>> activeStonesStream() {
    return _firestore
        .collection('stones')
        .where('isLost', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StoneModel.fromJson(doc.data()))
          .toList();
    });
  }
}
