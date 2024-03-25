import 'package:flutter/material.dart';

class AgriculturalLoanScreen extends StatelessWidget {
  const AgriculturalLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Loan'),
      ),
      body: const Center(
        child: Text('Details about School Fees Loan'),
      ),
    );
  }
}
