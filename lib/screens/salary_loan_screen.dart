import 'package:flutter/material.dart';

class SalaryLoanScreen extends StatelessWidget {
  const SalaryLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Loan'),
      ),
      body: const Center(
        child: Text('Details about School Fees Loan'),
      ),
    );
  }
}
