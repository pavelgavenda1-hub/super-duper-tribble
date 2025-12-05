import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stone_model.dart';
import 'diamond_service.dart';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DiamondService _diamondService = DiamondService();

  // Generate QR code string for a stone
  String generateQRCode(String stoneId) {
    return 'wts://stone/$stoneId';
  }

  // Validate QR code and return stone data
  Future<StoneModel?> validateQRCode(String qrCode) async {
    try {
      // Parse QR code
      if (!qrCode.startsWith('wts://stone/')) {
        print('Invalid QR code format');
        return null;
      }

      // Extract stone ID
      final stoneId = qrCode.replaceFirst('wts://stone/', '');

      // Fetch stone from Firestore
      final doc = await _firestore.collection('stones').doc(stoneId).get();

      if (!doc.exists) {
        print('Stone not found');
        return null;
      }

      // Return stone model
      return StoneModel.fromJson(doc.data()!);
    } catch (e) {
      print('Error validating QR code: $e');
      return null;
    }
  }

  // Scan QR code (placeholder - actual scanning happens in the UI)
  // This method is called after a QR code is scanned
  Future<StoneModel?> processScannedCode(String scannedCode) async {
    return await validateQRCode(scannedCode);
  }

  // Create a new stone with QR code
  Future<StoneModel?> createStone({
    required String ownerId,
    GeoPoint? initialLocation,
  }) async {
    try {
      // Create new stone document
      final stoneRef = _firestore.collection('stones').doc();
      final stoneId = stoneRef.id;

      final stone = StoneModel(
        id: stoneId,
        qrCode: generateQRCode(stoneId),
        currentOwnerId: ownerId,
        currentLocation: initialLocation,
        previousOwners: [ownerId],
        history: initialLocation != null
            ? [
                LocationHistory(
                  location: initialLocation,
                  ownerId: ownerId,
                  timestamp: DateTime.now(),
                  story: 'Stone created',
                  photoUrl: null,
                ),
              ]
            : [],
        createdAt: DateTime.now(),
        isLost: false,
      );

      await stoneRef.set(stone.toJson());
      return stone;
    } catch (e) {
      print('Error creating stone: $e');
      return null;
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
}
