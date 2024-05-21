import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How To'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'How to Navigate the App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInstruction(
            context,
            '1. Ensure Internet Connection',
            'You must have an internet connection to use the application. Make sure your device is connected to the internet before you start using the app.',
          ),
          const Divider(),
          _buildInstruction(
            context,
            '2. Sign Up and Login',
            'To start using the app, you need to create an account. On the main screen, tap on "Sign Up" and fill in your details. Once registered, you can log in using your credentials.',
          ),
          const Divider(),
          _buildInstruction(
            context,
            '3. Access Savings Plans',
            'Navigate to the "Savings Plan" section from the main menu. Here you can choose between monthly, weekly, daily, and one-time savings plans.',
          ),
          const Divider(),
          _buildInstruction(
            context,
            '4. Create a Savings Plan',
            'In the "Savings Plan" section, select your desired plan (monthly, weekly, daily, or one-time). Follow the prompts to set up your savings amount and schedule.',
          ),
          const Divider(),
          _buildInstruction(
            context,
            '5. Make a Savings Payment',
            'To make a payment towards your savings, go to the "Payments" section. Select your savings plan and choose your payment method. Follow the instructions to complete the payment.',
          ),
          const Divider(),
          _buildInstruction(
            context,
            '6. View Your Profile',
            'You can view and edit your profile by navigating to the "Profile" page from the main menu. Here, you can update your personal information and view your savings history.',
          ),
          const Divider(),
          _buildInstruction(
            context,
            '7. Contact Customer Care',
            'If you need help, go to the "Contact Us" section from the main menu. Here you will find options to reach out to customer support via phone, email, or chat.',
          ),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'For more detailed instructions, please visit our website or contact customer support.',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
