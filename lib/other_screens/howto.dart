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
            '1. Ensure Internet Connection',
            'You must have an internet connection to use the application. Make sure your device is connected to the internet before you start using the app.',
            null, // No image for this instruction
          ),
          const Divider(),
          _buildInstruction(
            '2. Sign Up',
            'To start using the app, you need to create an account. On the main screen, tap on "Sign Up" and fill in your details.Note you must fill all fields to be able to sign up including the Profile Photo If sign up is successful you will be led to the login screen',
            'assets/images/2.jpg', 
          ),
          const Divider(),
          _buildInstruction(
            '3. Login',
            'Here you can log in using your the credentials you used to sign up. After Successfuly logging in you will be led to the apps main screen',
            'assets/images/1.jpg', 
          ),
          const Divider(),
          _buildInstruction(
            '4. Main Screen Before transacting',
            'Here you can log in using your the credentials you used to sign up. After Successfuly logging in you will be led to the apps main screen',
            'assets/images/5.jpg', 
          ),
          const Divider(),
          _buildInstruction(
            '5. Access Saving Plans',
            'Navigate to the "Saving Plans" section from the main menu. Here you can choose between monthly, weekly, daily, and one-time savings plans but we recommend the Montlhy saving plan becuase it is the most ideal.',
            'assets/images/12.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '6. Create a Saving Plan',
            'In the "Savings Plan" section, select your desired plan (monthly, weekly, daily, or one-time). Follow the prompts to set up your savings amount and schedule.',
            'assets/images/14.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '7. Make a Saving Payment',
            'To make a payment towards your savings, go to the "Payments" section. Select your savings plan and choose your payment method. Follow the instructions to complete the payment.',
            'assets/images/15.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '8. View Your Profile',
            'You can view profile here.',
            'assets/images/11.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '9. How to make saving payments',
            'When you tap save and pay you will be let to a screen like this one.',
            'assets/images/16.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '10. Main Screen After transacting',
            'After transascting the main screen should  look like this the Transaction screen should have the Transaction you have carried out and the Your returns will be added on every transactionyou carry out.',
            'assets/images/24.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '11. Contact Customer Care via Phone call email and 24/7 WhatsApp number',
            'For any kinf os support please follow this and also we have a WhatsApp number that is available 24/7.',
            'assets/images/10.jpg',
          ),
          const Divider(),
          _buildInstruction(
            '12. Services and products coming soon',
            'We have a wide range of services we are preparing some of them are Loans services through this application, Emergency fund, kings cogent card, kings cogent mobile wallet and many more.',
            null, // No image for this instruction
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

  Widget _buildInstruction(String title, String description, String? imagePath) {
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
          if (imagePath != null) ...[
            const SizedBox(height: 8),
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ],
        ],
      ),
    );
  }
}
