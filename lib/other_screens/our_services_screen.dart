import 'package:flutter/material.dart';

class OurServicesScreen extends StatelessWidget {
  const OurServicesScreen({Key? key}) : super(key: key);

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
            const Divider(), // Divider
            const SizedBox(height: 8), // Add some space
            const Text(
              'We also offer Saving schemes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
          const Icon(
            Icons.star,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            serviceName,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
