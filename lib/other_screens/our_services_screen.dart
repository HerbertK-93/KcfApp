// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class OurServicesScreen extends StatelessWidget {
  const OurServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceItem('Agricultural Loans'),
                _buildServiceItem('Business Loans'),
                _buildServiceItem('Personal Loans'),
                _buildServiceItem('School fees Loans'),
                _buildServiceItem('Car/Boda Loans'),
                _buildServiceItem('Group Loans'),
                _buildServiceItem('Salary Loans'),
                _buildServiceItem('Emergency Loans'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String serviceName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.orange,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            serviceName,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
