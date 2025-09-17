// lib/services/cloudinary_service.dart

import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class CloudinaryService {
  final String _cloudName = 'dajzinfub';
  final String _uploadPreset = 'duka-letu';
  
  Future<String> uploadImage(File imageFile) async {
    final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path, 
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary error: ${e.message}');
      rethrow;
    }
  }
}