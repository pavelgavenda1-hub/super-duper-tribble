import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/qr_service.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../stone/stone_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final QRService _qrService = QRService();
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Získej aktuálního uživatele
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nejste přihlášeni'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Získej data uživatele z Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userName = userDoc.data()?['name'] as String? ?? 'Unknown';

      // Získej aktuální polohu
      GeoPoint? currentLocation;
      try {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          currentLocation = GeoPoint(position.latitude, position.longitude);
        }
      } catch (e) {
        print('Nepodařilo se získat polohu: $e');
      }

      // Zpracuj skenování
      final response = await _qrService.processScan(
        qrCode: code,
        userId: currentUser.uid,
        userName: userName,
        currentLocation: currentLocation,
      );

      if (!mounted) return;

      // Stop camera
      await cameraController.stop();

      // Zpracuj výsledek
      switch (response.result) {
        case ScanResult.firstScan:
          // První skenování - kámen je nyní můj, otevři editaci
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Gratulujeme! Našli jste nový kámen! Nyní je váš.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StoneDetailScreen(
                stoneId: response.stone!.id,
                isFirstScan: true, // Flag pro otevření v edit módu
              ),
            ),
          );
          break;

        case ScanResult.rescan:
          // Opakované skenování - zobrazit detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kámen navštíven! +10 💎\nCelkem návštěv: ${response.stone!.visitCount}',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StoneDetailScreen(
                stoneId: response.stone!.id,
              ),
            ),
          );
          break;

        case ScanResult.invalid:
          // Neplatný kód
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Neplatný QR kód'),
              backgroundColor: Colors.red,
            ),
          );

          // Restartuj kameru pro další skenování
          if (mounted) {
            await cameraController.start();
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba při skenování: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Restartuj kameru
        await cameraController.start();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skenovat QR kód'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay with frame
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Namiřte kameru na QR kód kamene',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Zpracování QR kódu...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
