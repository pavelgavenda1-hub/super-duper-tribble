import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stone_model.dart';
import 'diamond_service.dart';

// Výsledek skenování QR kódu
enum ScanResult {
  firstScan, // První skenování - kámen se stává vlastnictvím uživatele
  rescan, // Opakované skenování - aktualizace lokace a počtu návštěv
  invalid, // Neplatný QR kód
}

// Odpověď ze skenování
class ScanResponse {
  final ScanResult result;
  final StoneModel? stone;
  final String? errorMessage;

  ScanResponse({
    required this.result,
    this.stone,
    this.errorMessage,
  });
}

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DiamondService _diamondService = DiamondService();

  // Generate QR code string for a stone
  String generateQRCode(String stoneId) {
    return 'wts://stone/$stoneId';
  }

  // Hlavní metoda pro zpracování skenování QR kódu
  Future<ScanResponse> processScan({
    required String qrCode,
    required String userId,
    required String userName,
    GeoPoint? currentLocation,
  }) async {
    try {
      // Validace formátu QR kódu
      if (!qrCode.startsWith('wts://stone/')) {
        return ScanResponse(
          result: ScanResult.invalid,
          errorMessage: 'Neplatný formát QR kódu',
        );
      }

      // Extrakce ID kamene
      final stoneId = qrCode.replaceFirst('wts://stone/', '');

      // Zkontroluj, zda kámen existuje v databázi
      final doc = await _firestore.collection('stones').doc(stoneId).get();

      if (!doc.exists) {
        // PRVNÍ SKENOVÁNÍ - Vytvoř nový kámen a přiřaď vlastníka
        final newStone = await _createNewStone(
          stoneId: stoneId,
          qrCode: qrCode,
          ownerId: userId,
          ownerName: userName,
          currentLocation: currentLocation,
        );

        if (newStone != null) {
          // Přidělení diamantů za nalezení nového kamene
          await _diamondService.awardDiamonds(
            userId: userId,
            amount: 50,
            reason: 'Nalezen nový kámen',
            relatedStoneId: stoneId,
          );

          return ScanResponse(
            result: ScanResult.firstScan,
            stone: newStone,
          );
        } else {
          return ScanResponse(
            result: ScanResult.invalid,
            errorMessage: 'Nepodařilo se vytvořit kámen',
          );
        }
      } else {
        // OPAKOVANÉ SKENOVÁNÍ - Aktualizuj lokaci a počet návštěv
        final stone = StoneModel.fromJson(doc.data()!);
        final updatedStone = await _updateStoneVisit(
          stone: stone,
          userId: userId,
          currentLocation: currentLocation,
        );

        if (updatedStone != null) {
          // Přidělení diamantů za návštěvu kamene
          await _diamondService.awardDiamonds(
            userId: userId,
            amount: 10,
            reason: 'Návštěva kamene',
            relatedStoneId: stoneId,
          );

          return ScanResponse(
            result: ScanResult.rescan,
            stone: updatedStone,
          );
        } else {
          return ScanResponse(
            result: ScanResult.invalid,
            errorMessage: 'Nepodařilo se aktualizovat kámen',
          );
        }
      }
    } catch (e) {
      print('Error processing scan: $e');
      return ScanResponse(
        result: ScanResult.invalid,
        errorMessage: 'Chyba při zpracování QR kódu: $e',
      );
    }
  }

  // Vytvoření nového kamene při prvním skenování
  Future<StoneModel?> _createNewStone({
    required String stoneId,
    required String qrCode,
    required String ownerId,
    required String ownerName,
    GeoPoint? currentLocation,
  }) async {
    try {
      final stone = StoneModel(
        id: stoneId,
        qrCode: qrCode,
        ownerId: ownerId,
        ownerName: ownerName,
        currentLocation: currentLocation,
        history: currentLocation != null
            ? [
                LocationHistory(
                  location: currentLocation,
                  ownerId: ownerId,
                  timestamp: DateTime.now(),
                  story: 'Kámen nalezen poprvé',
                  photoUrl: null,
                ),
              ]
            : [],
        createdAt: DateTime.now(),
        isLost: false,
        visitCount: 1,
        isPublic: true,
      );

      await _firestore.collection('stones').doc(stoneId).set(stone.toJson());
      return stone;
    } catch (e) {
      print('Error creating stone: $e');
      return null;
    }
  }

  // Aktualizace kamene při opakovaném skenování
  Future<StoneModel?> _updateStoneVisit({
    required StoneModel stone,
    required String userId,
    GeoPoint? currentLocation,
  }) async {
    try {
      // Vytvoř nový záznam historie
      final newHistoryEntry = LocationHistory(
        location: currentLocation ?? stone.currentLocation!,
        ownerId: userId,
        timestamp: DateTime.now(),
        story: null,
        photoUrl: null,
      );

      // Aktualizuj kámen
      final updatedStone = stone.copyWith(
        currentLocation: currentLocation ?? stone.currentLocation,
        visitCount: stone.visitCount + 1,
        history: [...stone.history, newHistoryEntry],
      );

      await _firestore
          .collection('stones')
          .doc(stone.id)
          .update(updatedStone.toJson());

      return updatedStone;
    } catch (e) {
      print('Error updating stone visit: $e');
      return null;
    }
  }

  // Získání všech kamenů vlastněných uživatelem
  Future<List<StoneModel>> getUserStones(String userId) async {
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

  // Stream kamenů vlastněných uživatelem
  Stream<List<StoneModel>> userStonesStream(String userId) {
    return _firestore
        .collection('stones')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoneModel.fromJson(doc.data()))
            .toList());
  }

  // Aktualizace informací o kameni (pouze pro vlastníka)
  Future<bool> updateStone({
    required String stoneId,
    required String userId,
    String? name,
    String? story,
    List<String>? photos,
    bool? isPublic,
  }) async {
    try {
      final doc = await _firestore.collection('stones').doc(stoneId).get();
      if (!doc.exists) return false;

      final stone = StoneModel.fromJson(doc.data()!);

      // Ověř, že uživatel je vlastník
      if (stone.ownerId != userId) {
        print('User is not the owner of this stone');
        return false;
      }

      // Vytvoř mapu pro update
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (story != null) updates['story'] = story;
      if (photos != null) updates['photos'] = photos;
      if (isPublic != null) updates['isPublic'] = isPublic;

      await _firestore.collection('stones').doc(stoneId).update(updates);
      return true;
    } catch (e) {
      print('Error updating stone: $e');
      return false;
    }
  }

  // Get stone by ID
  Future<StoneModel?> getStoneById(String stoneId) async {
    try {
      final doc = await _firestore.collection('stones').doc(stoneId).get();
      if (doc.exists) {
        return StoneModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting stone: $e');
      return null;
    }
  }

  // Stream of stone data
  Stream<StoneModel?> stoneStream(String stoneId) {
    return _firestore.collection('stones').doc(stoneId).snapshots().map((doc) {
      if (doc.exists) {
        return StoneModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Stream všech kamenů
  Stream<List<StoneModel>> allStonesStream() {
    return _firestore.collection('stones').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StoneModel.fromJson(doc.data())).toList());
  }

  // Označení kamene jako ztraceného
  Future<bool> markStoneAsLost(String stoneId, String userId) async {
    try {
      final doc = await _firestore.collection('stones').doc(stoneId).get();
      if (!doc.exists) return false;

      final stone = StoneModel.fromJson(doc.data()!);

      // Pouze vlastník může označit kámen jako ztracený
      if (stone.ownerId != userId) return false;

      await _firestore.collection('stones').doc(stoneId).update({
        'isLost': true,
      });

      return true;
    } catch (e) {
      print('Error marking stone as lost: $e');
      return false;
    }
  }
}
