import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlutterwaveService {
  final String _baseUrl = 'https://api.flutterwave.com/v3';
  late final String _secretKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FlutterwaveService() {
    _secretKey = "FLWSECK-175bd285fceb48d9f8b437a3bfa32ee9-19192cf141cvt-X";
    if (_secretKey.isEmpty) {
      throw Exception('Flutterwave secret key is not set in the environment variables.');
    }
  }

  Future<void> storeDepositTransaction(Map<String, dynamic> transactionData) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final txRef = transactionData['tx_ref'];
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(txRef)
            .set(transactionData);  // Store the transaction with "pending" status
        print("Transaction stored successfully under user $uid with tx_ref $txRef");
      } catch (e) {
        print("Error storing transaction: $e");
        throw Exception('Failed to store transaction');
      }
    } else {
      print("User not authenticated");
      throw Exception('User not authenticated');
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String txRef,
    required String amount,
    required String currency,
    required String redirectUrl,
    required String email,
    required String phoneNumber,
    required String paymentType,
    required String paymentOptions,
    required String transactionType,  // Add this parameter
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

    final transactionData = {
      'tx_ref': txRef,
      'amount': amount,
      'currency': currency,
      'status': 'pending',
      'date': DateTime.now().toIso8601String(),
      'email': email,
      'transaction_type': transactionType,  // Store the transaction type (deposit, monthly, etc.)
    };

    // Store the transaction in Firestore before returning response
    await storeDepositTransaction(transactionData);

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
        final transactionData = {
          'tx_ref': txRef,
          'amount': response['data']['amount'],
          'currency': response['data']['currency'],
          'status': 'successful',
          'date': DateTime.now().toIso8601String(),
          'email': response['data']['customer']['email'],
          'transaction_type': response['data']['transaction_type'], // Ensure this is maintained
        };
        await storeDepositTransaction(transactionData);  // Update transaction status to "successful"
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking transaction status: $e');
      return false;
    }
  }
}
