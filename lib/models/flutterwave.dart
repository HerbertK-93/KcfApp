import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FlutterwaveService {
  final String _baseUrl = 'https://api.flutterwave.com/v3';
  late final String _secretKey;

  FlutterwaveService() {
    _secretKey = dotenv.env['FLUTTERWAVE_SECRET_KEY'] ?? '';
    if (_secretKey.isEmpty) {
      throw Exception('Flutterwave secret key is not set in the environment variables.');
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String txRef,
    required String amount,
    required String currency,
    required String redirectUrl,
    required String email,
    required String phoneNumber,
    required String paymentType, required String paymentOptions, // "card", "mobilemoney", "bank_transfer"
  }) async {
    final url = Uri.parse('$_baseUrl/payments');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_secretKey',
      },
      body: jsonEncode({
        'tx_ref': txRef,
        'amount': amount,
        'currency': currency,
        'redirect_url': redirectUrl,
        'payment_type': paymentType,
        'customer': {
          'email': email,
          'phonenumber': phoneNumber,
        },
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String txRef) async {
    final url = Uri.parse('$_baseUrl/transactions/$txRef/verify');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_secretKey',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }

  Future<bool> checkTransactionStatus(String txRef) async {
    try {
      final response = await verifyPayment(txRef);
      if (response['status'] == 'success' && response['data']['status'] == 'successful') {
        return true;  // Payment was successful
      }
      return false;  // Payment was not successful
    } catch (e) {
      print('Error checking transaction status: $e');
      return false;  // Treat as unsuccessful if there's an error
    }
  }
}
