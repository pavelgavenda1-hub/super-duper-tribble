import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/stone_model.dart';
import '../utils/stone_validation_util.dart';
import 'location_service.dart';

class MoveResult {
  final bool success;
  final String? errorMessage;
  final StoneModel? stone;

  MoveResult({
    required this.success,
    this.errorMessage,
    this.stone,
  });
}

class StoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  // Move stone to new location
  Future<MoveResult> moveStone({
    required String stoneId,
    required String userId,
    required Position newPosition,
    String? story,
    String? photoUrl,
  }) async {
    try {
      // Get stone data
      final stoneDoc = await _firestore.collection('stones').doc(stoneId).get();
      if (!stoneDoc.exists) {
        return MoveResult(
          success: false,
          errorMessage: 'Kámen nebyl nalezen',
        );
      }

      final stone = StoneModel.fromJson(stoneDoc.data()!);

      // Validate move
      final validation = StoneValidationUtil.validateAllMoveRequirements(
        stone: stone,
        userId: userId,
        newPosition: newPosition,
      );

      if (!validation.isValid) {
        return MoveResult(
          success: false,
          errorMessage: validation.errorMessage,
        );
      }

      // Get country from location
      final country = await _locationService.getCountryFromLocation(
        newPosition.latitude,
        newPosition.longitude,
      );

      // Create new location history entry
      final newHistory = LocationHistory(
        location: GeoPoint(newPosition.latitude, newPosition.longitude),
        ownerId: userId,
        timestamp: DateTime.now(),
        story: story,
        photoUrl: photoUrl,
      );

      // Update stone data
      final updatedHistory = [...stone.history, newHistory];
      final updatedPreviousOwners = stone.previousOwners.contains(userId)
          ? stone.previousOwners
          : [...stone.previousOwners, userId];

      final updatedStone = stone.copyWith(
        currentOwnerId: userId,
        currentLocation: GeoPoint(newPosition.latitude, newPosition.longitude),
        history: updatedHistory,
        previousOwners: updatedPreviousOwners,
      );

      // Save to Firestore
      await _firestore
          .collection('stones')
          .doc(stoneId)
          .update(updatedStone.toJson());

      return MoveResult(
        success: true,
        stone: updatedStone,
      );
    } catch (e) {
      print('Error moving stone: $e');
      return MoveResult(
        success: false,
        errorMessage: 'Chyba při přemístění kamene: ${e.toString()}',
      );
    }
  }

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

  // Get stones by user
  Future<List<StoneModel>> getStonesByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('stones')
          .where('previousOwners', arrayContains: userId)
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
