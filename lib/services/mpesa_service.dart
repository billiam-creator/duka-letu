import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  final String baseUrl = "https://79025e3fe1a1.ngrok-free.app"; // ✅ your ngrok URL

  Future<Map<String, dynamic>> initiateStkPush(String phone, int amount) async {
    try {
      final url = Uri.parse("$baseUrl/stkpush"); // ✅ backend route

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "phone": phone,     // must be 2547XXXXXXX format
          "amount": amount,   // e.g. 1 for sandbox
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error initiating STK Push: $e");
    }
  }
}
