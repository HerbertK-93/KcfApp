import 'package:flutter/material.dart';
import 'package:kings_cogent/other_screens/about_us_screen.dart';
import 'package:kings_cogent/other_screens/contact_us_screen.dart';
import 'package:kings_cogent/other_screens/our_services_screen.dart';
import 'package:kings_cogent/other_screens/our_team_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(193, 90, 201, 248),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context,
            'About Us',
            const AboutUsScreen(),
            Icons.arrow_forward,
          ),
          const Divider(),
          _buildMenuItem(
            context,
            'Contact Us',
            const ContactUsScreen(),
            Icons.arrow_forward,
          ),
          const Divider(),
          _buildMenuItem(
            context,
            'Our Team',
            const OurTeamScreen(),
            Icons.arrow_forward,
          ),
          const Divider(),
          _buildMenuItem(
            context,
            'Our Services',
            const OurServicesScreen(),
            Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    Widget screen,
    IconData icon,
  ) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      trailing: Icon(icon),
    );
  }
}
