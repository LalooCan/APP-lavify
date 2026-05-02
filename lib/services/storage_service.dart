import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickPhoto({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('StorageService.pickPhoto error: $e');
      return null;
    }
  }

  Future<String?> uploadProfilePhoto(String uid, XFile file) async {
    try {
      final ref = _storage.ref('profile_photos/$uid.jpg');
      final bytes = await file.readAsBytes();
      final task = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadProfilePhoto error: $e');
      return null;
    }
  }

  Future<void> deleteProfilePhoto(String uid) async {
    try {
      await _storage.ref('profile_photos/$uid.jpg').delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        debugPrint('StorageService.deleteProfilePhoto error: $e');
      }
    }
  }
}
