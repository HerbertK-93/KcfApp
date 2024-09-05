import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit')),
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
            ],
          ),
        ),
      ),
    );
  }
}
