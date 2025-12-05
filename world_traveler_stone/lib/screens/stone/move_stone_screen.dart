import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/stone_model.dart';
import '../../services/location_service.dart';
import '../../services/stone_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';

class MoveStoneScreen extends StatefulWidget {
  final StoneModel stone;

  const MoveStoneScreen({
    super.key,
    required this.stone,
  });

  @override
  State<MoveStoneScreen> createState() => _MoveStoneScreenState();
}

class _MoveStoneScreenState extends State<MoveStoneScreen> {
  final _storyController = TextEditingController();
  final _locationService = LocationService();
  final _stoneService = StoneService();
  final _storageService = StorageService();
  final _authService = AuthService();

  Position? _currentPosition;
  File? _selectedImage;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  String? _locationAddress;

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentPosition = position;
        });

        // Get address
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _locationAddress = address;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poloha získána úspěšně'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nepodařilo se získat polohu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Vyfotit'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _storageService.takePhoto();
                if (image != null) {
                  setState(() {
                    _selectedImage = image;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Vybrat z galerie'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _storageService.pickImageFromGallery();
                if (image != null) {
                  setState(() {
                    _selectedImage = image;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitMove() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nejdřív získejte svou polohu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nejste přihlášeni'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? photoUrl;

      // Upload photo if selected
      if (_selectedImage != null) {
        photoUrl = await _storageService.uploadStonePhoto(
          stoneId: widget.stone.id,
          userId: currentUser.uid,
          imageFile: _selectedImage!,
        );
      }

      // Move stone
      final result = await _stoneService.moveStone(
        stoneId: widget.stone.id,
        userId: currentUser.uid,
        newPosition: _currentPosition!,
        story: _storyController.text.isNotEmpty ? _storyController.text : null,
        photoUrl: photoUrl,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kámen byl úspěšně přemístěn!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Chyba při přemístění'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Přemístit kámen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _currentPosition != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              size: 50, color: Colors.blue),
                          const SizedBox(height: 10),
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (_locationAddress != null) ...[
                            const SizedBox(height: 5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _locationAddress!,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 50, color: Colors.grey[600]),
                          const SizedBox(height: 10),
                          Text(
                            'Poloha nebyla získána',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Get location button
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLoadingLocation
                  ? 'Získávám polohu...'
                  : 'Získat moji polohu'),
            ),

            const SizedBox(height: 20),

            // Story field
            TextField(
              controller: _storyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Váš příběh (volitelné)',
                hintText: 'Napište něco o tomto místě...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Photo section
            if (_selectedImage != null)
              Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            // Add photo button
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Přidat fotografii (volitelné)'),
            ),

            const SizedBox(height: 30),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitMove,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Potvrdit přemístění',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
