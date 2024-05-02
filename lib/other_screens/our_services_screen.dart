import 'package:flutter/material.dart';

class OurServicesScreen extends StatelessWidget {
  const OurServicesScreen({Key? key});

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
                _buildServiceItem('School Fees Loans'),
                _buildServiceItem('Car/Boda Loans'),
                _buildServiceItem('Group Loans'),
                _buildServiceItem('Salary Loans'),
                _buildServiceItem('Emergency Loans'),
              ],
            ),
            const Divider(), // Divider
            const SizedBox(height: 8), // Add some space
            const Text(
              'Saving Plans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildSavingPlanItem(
              name: 'Monthly Plan',
              icon: Icons.calendar_today,
            ),
            _buildSavingPlanItem(
              name: 'Weekly Plan',
              icon: Icons.calendar_view_week,
            ),
            _buildSavingPlanItem(
              name: 'Daily Plan',
              icon: Icons.today,
            ),
            _buildSavingPlanItem(
              name: 'One-time Plan',
              icon: Icons.monetization_on,
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

  Widget _buildSavingPlanItem({required String name, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5), // Adjust left padding here
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
