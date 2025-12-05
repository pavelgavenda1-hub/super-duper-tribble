import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DiamondService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Award diamonds to user
  Future<bool> awardDiamonds({
    required String userId,
    required int amount,
    required String reason,
    String? relatedStoneId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Create transaction
      final transaction = DiamondTransaction(
        amount: amount,
        reason: reason,
        timestamp: DateTime.now(),
        relatedStoneId: relatedStoneId,
      );

      // Update user document
      await userRef.update({
        'diamonds': FieldValue.increment(amount),
        'diamondHistory': FieldValue.arrayUnion([transaction.toJson()]),
      });

      return true;
    } catch (e) {
      print('Error awarding diamonds: $e');
      return false;
    }
  }

  // Get user's diamond balance
  Future<int> getDiamondsBalance(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['diamonds'] as int? ?? 0;
    } catch (e) {
      print('Error getting diamond balance: $e');
      return 0;
    }
  }

  // Deduct diamonds from user
  Future<bool> deductDiamonds({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final currentBalance = userDoc.data()?['diamonds'] as int? ?? 0;

      if (currentBalance < amount) {
        print('Insufficient diamonds');
        return false;
      }

      final transaction = DiamondTransaction(
        amount: -amount,
        reason: reason,
        timestamp: DateTime.now(),
      );

      await userRef.update({
        'diamonds': FieldValue.increment(-amount),
        'diamondHistory': FieldValue.arrayUnion([transaction.toJson()]),
      });

      return true;
    } catch (e) {
      print('Error deducting diamonds: $e');
      return false;
    }
  }

  // Get diamond history
  Future<List<DiamondTransaction>> getDiamondHistory(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final history = doc.data()?['diamondHistory'] as List<dynamic>? ?? [];

      return history
          .map((t) => DiamondTransaction.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting diamond history: $e');
      return [];
    }
  }

  // Award diamonds for finding a stone
  Future<void> awardForFindingStone({
    required String userId,
    required String stoneId,
    required bool isLostStone,
  }) async {
    final amount = isLostStone ? 500 : 50;
    final reason = isLostStone
        ? 'Nalezení ztraceného kamene'
        : 'Nalezení kamene';

    await awardDiamonds(
      userId: userId,
      amount: amount,
      reason: reason,
      relatedStoneId: stoneId,
    );
  }

  // Award diamonds for moving a stone
  Future<void> awardForMovingStone({
    required String userId,
    required String stoneId,
  }) async {
    await awardDiamonds(
      userId: userId,
      amount: 100,
      reason: 'Přemístění kamene',
      relatedStoneId: stoneId,
    );
  }

  // Award diamonds for international move
  Future<void> awardForInternationalMove({
    required String userId,
    required String stoneId,
    required String fromCountry,
    required String toCountry,
  }) async {
    await awardDiamonds(
      userId: userId,
      amount: 300,
      reason: 'Přesun do jiné země ($fromCountry → $toCountry)',
      relatedStoneId: stoneId,
    );
  }

  // Award diamonds for sharing story with photo
  Future<void> awardForSharingStory({
    required String userId,
    required String stoneId,
  }) async {
    await awardDiamonds(
      userId: userId,
      amount: 50,
      reason: 'Sdílení příběhu s fotografií',
      relatedStoneId: stoneId,
    );
  }
}
