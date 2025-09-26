import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MpesaProvider with ChangeNotifier {
  // Instance of Firebase Functions
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Function to call the Firebase Cloud Function for STK Push
  Future<Map<String, dynamic>> initiateStkPush(
      double amount, String phoneNumber) async {
    try {
      // 🚨 Important: Ensure your Cloud Function name matches exactly.
      // This assumes you deployed a function named 'initiateStkPush'
      final HttpsCallable callable =
          _functions.httpsCallable('initiateStkPush');

      // Prepare the data to send to the function
      final response = await callable.call(<String, dynamic>{
        'amount': amount,
        'phoneNumber': phoneNumber,
        // You might add more context like:
        // 'userId': userId,
        // 'orderId': orderId,
      });

      // The result from the Firebase Function is returned
      // It should be structured as {'success': bool, 'message': String, 'data': Map}
      return {
        'success': true,
        'message': 'STK Push initiated successfully.',
        'data': response.data as Map<String, dynamic>,
      };
    } on FirebaseFunctionsException catch (e) {
      // Handle errors returned directly from the cloud function
      print('Firebase Function Error: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': 'Payment failed. Error: ${e.message}',
        'data': {'code': e.code, 'details': e.details},
      };
    } catch (e) {
      // Handle any other general errors (network, parsing, etc.)
      print('General Error during STK Push: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'data': {},
      };
    }
  }
}