 import 'package:flutter/material.dart';

class EmergencyFundScreen extends StatelessWidget {
  const EmergencyFundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
      ),
      body: Center(
        child: const Text('Deposit Screen Content'),
      ),
    );
  }
}