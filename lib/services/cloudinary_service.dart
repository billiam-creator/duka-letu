import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For @required

class CloudinaryService {
  // 🚨 RENAME THESE PLACEHOLDERS TO YOUR ACTUAL CREDENTIALS 🚨
  static const String CLOUDINARY_CLOUD_NAME = 'dajzinfub';
  static const String CLOUDINARY_UPLOAD_PRESET = 'duka-letu';
  
  // The API endpoint for raw image uploads
  final String _uploadUrl = 'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload';

  /// Uploads a file (image) to Cloudinary.
  /// Returns the secure URL of the uploaded image on success, or null on failure.
  Future<String?> uploadImage(File imageFile) async {
    if (CLOUDINARY_CLOUD_NAME == 'YOUR_CLOUD_NAME_HERE') {
      debugPrint('Cloudinary credentials not set. Image upload skipped.');
      // Return a placeholder URL for testing if needed
      return 'https://via.placeholder.com/300x200.png?text=Placeholder'; 
    }
    
    try {
      // 1. Create the Multipart Request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // 2. Add the necessary fields
      request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;

      // 3. Add the file to the request
      final file = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(file);

      // 4. Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        final String secureUrl = data['secure_url'];
        debugPrint('Image uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('Cloudinary upload failed with status ${response.statusCode}: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Error during Cloudinary upload: $e');
      return null;
    }
  }
}



