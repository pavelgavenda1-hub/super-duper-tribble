import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/qr_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/stone_model.dart';

class StoneDetailScreen extends StatefulWidget {
  final String stoneId;
  final bool isFirstScan;

  const StoneDetailScreen({
    super.key,
    required this.stoneId,
    this.isFirstScan = false,
  });

  @override
  State<StoneDetailScreen> createState() => _StoneDetailScreenState();
}

class _StoneDetailScreenState extends State<StoneDetailScreen> {
  final QRService _qrService = QRService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  bool _isEditMode = false;
  bool _isLoading = false;

  // Edit controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  List<String> _photos = [];
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    // Pokud je to první skenování, otevři rovnou edit mód
    if (widget.isFirstScan) {
      _isEditMode = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      // Upload to Firebase Storage
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final photoUrl = await _storageService.uploadStonePhoto(
        userId: currentUser.uid,
        stoneId: widget.stoneId,
        imageFile: File(image.path),
      );

      if (photoUrl != null) {
        setState(() {
          _photos.add(photoUrl);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba při nahrávání fotky: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveStone() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _qrService.updateStone(
        stoneId: widget.stoneId,
        userId: currentUser.uid,
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        story: _storyController.text.trim().isEmpty
            ? null
            : _storyController.text.trim(),
        photos: _photos,
        isPublic: _isPublic,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kámen byl úspěšně aktualizován'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditMode = false;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nepodařilo se aktualizovat kámen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadStoneData(StoneModel stone) {
    if (_nameController.text.isEmpty && stone.name != null) {
      _nameController.text = stone.name!;
    }
    if (_storyController.text.isEmpty && stone.story != null) {
      _storyController.text = stone.story!;
    }
    if (_photos.isEmpty && stone.photos.isNotEmpty) {
      _photos = List.from(stone.photos);
    }
    _isPublic = stone.isPublic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editace kamene' : 'Detail kamene'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveStone,
            ),
        ],
      ),
      body: StreamBuilder<StoneModel?>(
        stream: _qrService.stoneStream(widget.stoneId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Chyba: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Kámen nebyl nalezen'),
            );
          }

          final stone = snapshot.data!;
          final currentUser = _authService.currentUser;
          final isOwner = currentUser?.uid == stone.ownerId;

          // Load data for edit mode
          if (_isEditMode) {
            _loadStoneData(stone);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stone header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Icon(
                        Icons.place,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      if (_isEditMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Název kamene',
                              hintText: 'Např. "Kámen z Prahy"',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Text(
                          stone.name ?? 'Kámen #${stone.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Vlastník: ${stone.ownerName ?? "Neznámý"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Vytvořeno: ${DateFormat('dd.MM.yyyy').format(stone.createdAt)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Info section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informace',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('Počet návštěv', '${stone.visitCount}'),
                      _buildInfoRow(
                        'Historie lokací',
                        '${stone.history.length}',
                      ),
                      _buildInfoRow(
                        'Status',
                        stone.isLost ? 'Ztracený' : 'Aktivní',
                      ),
                      _buildInfoRow(
                        'Viditelnost',
                        stone.isPublic ? 'Veřejný' : 'Soukromý',
                      ),
                    ],
                  ),
                ),

                // Story section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Příběh kamene',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isEditMode)
                        TextField(
                          controller: _storyController,
                          decoration: const InputDecoration(
                            labelText: 'Příběh',
                            hintText:
                                'Popište, kde jste kámen našli a co pro vás znamená...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        )
                      else if (stone.story != null && stone.story!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stone.story!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        Text(
                          'Zatím žádný příběh',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                // Photos section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fotky',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isEditMode)
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _pickImage,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Přidat'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_photos.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(_photos[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (_isEditMode)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      color: Colors.red,
                                      onPressed: () {
                                        setState(() {
                                          _photos.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      else
                        Text(
                          'Zatím žádné fotky',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                // Visibility toggle (only in edit mode)
                if (_isEditMode)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SwitchListTile(
                      title: const Text('Veřejný kámen'),
                      subtitle: const Text(
                        'Ostatní uživatelé mohou vidět váš příběh a fotky',
                      ),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                    ),
                  ),

                // Edit/Save buttons (only for owner)
                if (isOwner && !_isEditMode)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditMode = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Upravit kámen'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                if (_isEditMode)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isEditMode = false;
                                      // Reset controllers
                                      _nameController.clear();
                                      _storyController.clear();
                                      _photos.clear();
                                    });
                                  },
                            child: const Text('Zrušit'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveStone,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Uložit'),
                          ),
                        ),
                      ],
                    ),
                  ),

                // History section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historie návštěv',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (stone.history.isEmpty)
                        Text(
                          'Zatím žádná historie',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stone.history.length,
                          itemBuilder: (context, index) {
                            final history =
                                stone.history[stone.history.length - 1 - index];
                            return _buildHistoryCard(history);
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(LocationHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(history.timestamp),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lat: ${history.location.latitude.toStringAsFixed(4)}, '
                  'Lon: ${history.location.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (history.story != null) ...[
              const SizedBox(height: 8),
              Text(history.story!),
            ],
            if (history.photoUrl != null) ...[
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(history.photoUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
