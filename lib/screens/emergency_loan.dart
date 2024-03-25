import 'package:flutter/material.dart';

class EmergencyLoanScreen extends StatelessWidget {
  const EmergencyLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Loan'),
      ),
      body: const Center(
        child: Text('Details about School Fees Loan'),
      ),
    );
  }
}
