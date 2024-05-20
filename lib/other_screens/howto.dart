import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How To'),
      ),
      body: const Center(
        child: Text(
          'Instructions on how to use and navigate the app will go here.',
        ),
      ),
    );
  }
}