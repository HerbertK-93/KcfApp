import 'package:flutter/material.dart';

class PersonalLoanScreen extends StatelessWidget {
  const PersonalLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Loan'),
      ),
      body: const Center(
        child: Text('Details about School Fees Loan'),
      ),
    );
  }
}
