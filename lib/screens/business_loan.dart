import 'package:flutter/material.dart';

class BusinessLoanScreen extends StatelessWidget {
  const BusinessLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Loan'),
      ),
      body: const Center(
        child: Text('Details about School Fees Loan'),
      ),
    );
  }
}
