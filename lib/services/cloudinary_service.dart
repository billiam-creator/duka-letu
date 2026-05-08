import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dajzinfub';
  static const String uploadPreset = 'duka-letu';
  final String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Upload image bytes (works on Web, Android, iOS, Desktop)
  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        debugPrint('Cloudinary upload success: ${data['secure_url']}');
        return data['secure_url'] as String;
      } else {
        debugPrint('Cloudinary upload failed ${response.statusCode}: $body');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}