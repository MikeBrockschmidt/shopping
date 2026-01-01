import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();
  
  /// Upload image to Firebase Storage and return the download URL
  static Future<String> uploadItemImage(File imageFile, String groupId) async {
    try {
      // Resize image to 200x200
      final resizedImageBytes = await _resizeImage(imageFile, 200, 200);
      
      // Generate unique filename
      final fileName = '${_uuid.v4()}.jpg';
      final path = 'shopping-items/$groupId/$fileName';
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        resizedImageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'groupId': groupId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      print('Error uploading image: $e');
      
      // Check if it's a Firebase Storage not initialized error
      if (e.toString().contains('storage') || e.toString().contains('bucket')) {
        throw Exception('Firebase Storage ist nicht aktiviert. Bitte aktiviere es in der Firebase Console.');
      }
      
      throw Exception('Fehler beim Hochladen des Bildes: ${e.toString()}');
    }
  }
  
  /// Delete image from Firebase Storage
  static Future<void> deleteItemImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully: $imageUrl');
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw error - image might already be deleted
    }
  }
  
  /// Resize image to specified dimensions
  static Future<Uint8List> _resizeImage(File imageFile, int width, int height) async {
    // Read image bytes
    final imageBytes = await imageFile.readAsBytes();
    
    // Decode image
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Unable to decode image');
    }
    
    // Resize image maintaining aspect ratio and center crop
    final resized = img.copyResizeCropSquare(originalImage, size: width);
    
    // Encode as JPEG with quality 85
    final jpegBytes = img.encodeJpg(resized, quality: 85);
    
    return Uint8List.fromList(jpegBytes);
  }
  
  /// Get image size info
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Unable to decode image');
    }
    
    return {
      'width': image.width,
      'height': image.height,
    };
  }
}