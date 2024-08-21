import 'package:KcfApp/models/flutterwave.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KcfApp/providers/deposit_provider.dart';
import 'package:KcfApp/providers/transaction_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Email controller
  final FlutterwaveService _flutterwaveService = FlutterwaveService();

  String _selectedCurrency = 'UGX';

  final List<String> _currencies = ['UGX', 'USD', 'EUR', 'GBP', 'KES', 'NGN', 'ZAR'];

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _emailController.dispose(); // Dispose the email controller
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _initiatePayment() async {
    // Check if all required fields are filled
    if (_amountController.text.isEmpty || _emailController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all required fields')),
      );
      return;
    }

    try {
      final String txRef = DateTime.now().millisecondsSinceEpoch.toString();
      final String redirectUrl = 'yourapp://redirect';

      final paymentResponse = await _flutterwaveService.initiatePayment(
        txRef: txRef,
        amount: _amountController.text,
        currency: _selectedCurrency,
        redirectUrl: redirectUrl,
        email: _emailController.text, // Use the entered email
        phoneNumber: '1234567890',
        paymentType: 'mobilemoney', paymentOptions: '', // Set mobile money as the default payment method
      );

      final paymentLink = paymentResponse['data']['link'];

      if (await canLaunchUrl(Uri.parse(paymentLink))) {
        await launchUrl(Uri.parse(paymentLink));
        bool isSuccessful = await _flutterwaveService.checkTransactionStatus(txRef);
        if (isSuccessful) {
          final depositProvider = Provider.of<DepositProvider>(context, listen: false);
          final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

          // Add deposit to DepositProvider
          depositProvider.addDeposit(
            _amountController.text,
            _dateController.text,
            _selectedCurrency,
          );

          // Add transaction to TransactionProvider
          transactionProvider.addTransaction({
            'date': _dateController.text,
            'amount': double.parse(_amountController.text),
            'tx_ref': txRef,
            'status': 'successful',
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful and recorded')),
          );

          // Navigate back to the home screen or reset the form
          Navigator.pop(context);

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction failed or was cancelled')),
          );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              const Text('Enter Email'), // Email input field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initiatePayment,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
