import 'package:flutter/material.dart';

class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Text(
          'Payment Options',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.payment,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Your Preferred Payment Method',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showPaymentOptionsDialog(context);
              },
              child: const Text('Select Payment Method'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Select Payment')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(), // Divider before the options
              ListTile(
                title: const Text('MTN Mobile Money'),
                onTap: () {
                  // Handle MTN Mobile Money logic
                  Navigator.pop(context); // Close the dialog
                },
              ),
              const Divider(), // Divider between MTN Mobile Money and Airtel Money
              ListTile(
                title: const Text('Airtel Money'),
                onTap: () {
                  // Handle Airtel Money logic
                  Navigator.pop(context); // Close the dialog
                },
              ),
              const Divider(), // Divider between Airtel Money and Bank Transaction
              ListTile(
                title: const Text('Bank Transaction'),
                onTap: () {
                  // Handle Bank Transaction logic
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
