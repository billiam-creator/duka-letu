import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  // ✅ Update this to your current ngrok URL when running locally
  static const String baseUrl = "https://your-ngrok-url.ngrok-free.app";

  /// Normalize any valid Kenyan phone number to 2547XXXXXXXX or 2541XXXXXXXX
  static String normalizePhone(String raw) {
    String phone = raw.replaceAll(RegExp(r'[\s\-().]'), '');

    // Remove leading +
    if (phone.startsWith('+')) phone = phone.substring(1);

    // 07XX or 01XX → 254XX
    if (RegExp(r'^0[17]\d{8}$').hasMatch(phone)) {
      phone = '254${phone.substring(1)}';
    }

    // Validate: must be 254 + 7 or 1 + 8 more digits = 12 chars
    if (!RegExp(r'^254[17]\d{8}$').hasMatch(phone)) {
      throw Exception(
        'Invalid phone number: $raw\n'
        'Use formats like:\n'
        '• 0712 345 678 (Safaricom)\n'
        '• 0112 345 678 (Airtel)\n'
        '• +254712345678\n'
        '• 254112345678',
      );
    }

    return phone;
  }

  Future<Map<String, dynamic>> initiateStkPush(String phone, double amount) async {
    final normalizedPhone = normalizePhone(phone);

    try {
      final url = Uri.parse('$baseUrl/stkpush');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': normalizedPhone,
          'amount': amount.ceil(),
        }),
      );

      final body = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return body;
      } else {
        throw Exception(body['error'] ?? body['message'] ?? 'STK Push failed');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}