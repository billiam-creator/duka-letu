import 'package:flutter/foundation.dart';
import 'package:duka_letu/services/mpesa_service.dart';

class MpesaProvider with ChangeNotifier {
  final MpesaService _mpesaService = MpesaService();
  bool _isLoading = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<Map<String, dynamic>> initiateStkPush(
      double amount, String phoneNumber) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _mpesaService.initiateStkPush(phoneNumber, amount);
      return {
        'success': true,
        'message': 'STK Push initiated! Check your phone.',
        'data': result,
      };
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return {
        'success': false,
        'message': _lastError,
        'data': {},
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}