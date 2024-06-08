import 'package:flutter/material.dart';

class NavigationInstructionsScreen extends StatelessWidget {
  const NavigationInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Navigate'),
        backgroundColor: const Color.fromARGB(255, 64, 69, 69),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to navigate the app',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              _buildSectionTitle('1. Main Screen Overview'),
              const SizedBox(height: 10),
              _buildBulletPoint('Your returns – See how your investments are growing over time and your expected returns at the end of your saving period.'),
              _buildBulletPoint('Saving plans – Choose from monthly (most recommended), weekly, daily, and one-time saving plans.'),
              _buildBulletPoint('Transactions – View all your transactions, including making, saving, and paying transactions. Tap "view all" to see all transactions.'),
              _buildBulletPoint('WhatsApp Support – Tap the WhatsApp icon for 24/7 support for any questions and queries about the app.'),
              const SizedBox(height: 20),
              const Divider(color: Colors.teal),
              const SizedBox(height: 20),
              _buildSectionTitle('2. Saving Plans (Example: Monthly Saving Plan)'),
              const SizedBox(height: 10),
              _buildBulletPoint('Choose a saving plan, select a date, period, and amount to save. Note: You can only choose one saving plan.'),
              _buildBulletPoint('After selecting, save and pay. Your transaction will be saved, and you will be led to the payment window to complete the transaction.'),
              _buildBulletPoint('The process is the same for all other saving plans.'),
              _buildSubBulletPoint('Monthly Plan – Save an amount once every month for the selected period.'),
              _buildSubBulletPoint('Weekly Plan – Save an amount once every week for the selected period.'),
              _buildSubBulletPoint('Daily Plan – Save an amount every day for the selected period.'),
              _buildSubBulletPoint('One-time Plan – Save an amount once for the selected period.'),
              const SizedBox(height: 20),
              const Divider(color: Colors.teal),
              const SizedBox(height: 20),
              _buildSectionTitle('3. Viewing Your Profile'),
              const SizedBox(height: 10),
              _buildBulletPoint('Tap the profile icon to view your profile. You will be able to view your Sign Up information here and the upcoming KINGS COGENT CARD with various benefits.'),
              const SizedBox(height: 20),
              const Divider(color: Colors.teal),
              const SizedBox(height: 20),
              _buildSectionTitle('4. The Menu Button'),
              const SizedBox(height: 10),
              _buildBulletPoint('Tap the menu icon on the left side of your screen to access settings and more pages.'),
              _buildBulletPoint('Settings – Find more detailed and visualized instructions on how to navigate the app.'),
              _buildBulletPoint('Share – Tap the share icon to share the app with others via Message and WhatsApp.'),
              _buildBulletPoint('Logout – Tap the logout icon to log out of the application.'),
              _buildBulletPoint('More – Access the Contact Us page with company emails, contacts, and a link to the company website for additional support.'),
              const SizedBox(height: 20),
              const Divider(color: Colors.teal),
              const SizedBox(height: 20),
              _buildSectionTitle('5. Coming Soon'),
              const SizedBox(height: 10),
              _buildBulletPoint('Loans – Get loans with good interest rates.'),
              _buildBulletPoint('Emergency Fund – Access funds for health or financial emergencies.'),
              _buildBulletPoint('Kings Cogent Visa Card and Mobile Wallet – Access debit and credit services and perform more transactions using the app.'),
              _buildBulletPoint('Awards – Receive awards at the end of each financial year for being our best customer.'),
              _buildBulletPoint('And many more features coming soon.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.brightness_1, color: Colors.teal, size: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
