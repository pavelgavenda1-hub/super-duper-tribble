import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload stone photo to Firebase Storage
  Future<String?> uploadStonePhoto({
    required String stoneId,
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'stones/$stoneId/${userId}_$timestamp.jpg';

      // Upload file
      final ref = _storage.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }

      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Take photo with camera
  Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }

      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Delete photo from storage
  Future<bool> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  // Upload user profile photo
  Future<String?> uploadUserPhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = 'users/$userId/profile.jpg';
      final ref = _storage.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading user photo: $e');
      return null;
    }
  }
}
