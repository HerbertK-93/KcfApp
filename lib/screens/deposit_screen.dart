import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';  // For formatting date and time
import 'package:KcfApp/models/flutterwave.dart';
import 'package:KcfApp/providers/deposit_provider.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FlutterwaveService _flutterwaveService = FlutterwaveService();

  String _selectedCurrency = 'UGX';
  final List<String> _currencies = ['UGX', 'USD', 'EUR', 'GBP', 'KES', 'NGN', 'ZAR'];
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (_amountController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all required fields')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final String txRef = DateTime.now().millisecondsSinceEpoch.toString();
      final String redirectUrl = 'yourapp://redirect';

      final paymentResponse = await _flutterwaveService.initiatePayment(
        txRef: txRef,
        amount: _amountController.text,
        currency: _selectedCurrency,
        redirectUrl: redirectUrl,
        email: _emailController.text,
        phoneNumber: '1234567890',
        paymentType: 'mobilemoney',
        paymentOptions: '',
        transactionType: 'deposit',
      );

      final paymentLink = paymentResponse['data']['link'];

      if (await canLaunchUrl(Uri.parse(paymentLink))) {
        await launchUrl(Uri.parse(paymentLink), mode: LaunchMode.externalApplication);
        bool isSuccessful = await _flutterwaveService.checkTransactionStatus(txRef);
        if (isSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful and recorded')),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch payment link')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment initiation failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Fetch all deposit transactions from Firestore in real-time
  Stream<QuerySnapshot> _getDepositTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)  // Fetch transactions for the current user
        .collection('transactions')
        .where('transaction_type', isEqualTo: 'deposit')  // Filter for 'deposit' transactions
        .snapshots();
  }

  // Function to format the date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y, h:mm a').format(dateTime);  // Format: Aug 20, 2023, 4:30 PM
  }

  // Function to get a status icon
  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'failed':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  // UI for the Deposits section below the Confirm button
Widget _buildDepositList() {
  return StreamBuilder<QuerySnapshot>(
    stream: _getDepositTransactionsStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Text('No deposits found.');
      }

      // List of deposit transactions (already sorted by date, newest first)
      final deposits = snapshot.data!.docs;

      return ListView.builder(
        itemCount: deposits.length,
        itemBuilder: (context, index) {
          final deposit = deposits[index].data() as Map<String, dynamic>;
          final amount = deposit['amount'];
          final currency = deposit['currency'];
          final status = deposit['status'];
          final date = DateTime.parse(deposit['date']);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currency $amount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _getStatusIcon(status),  // Status icon
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: status == 'successful'
                              ? Colors.green
                              : (status == 'pending' ? Colors.orange : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Deposit')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Enter Amount'),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter the amount',
              suffix: SizedBox(
                height: 24,
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                  underline: Container(),
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text('Enter Email'),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Deposits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Wrapping this in Expanded to allow it to take the remaining space and scroll
          Expanded(
            child: _buildDepositList(),  // Show the deposit transactions list here with enhanced UI
          ),
        ],
      ),
    ),
  );
}
}