import 'package:flutter/material.dart';
import 'package:KcfApp/other_screens/about_us_screen.dart';
import 'package:KcfApp/other_screens/our_services_screen.dart';
import 'package:KcfApp/other_screens/our_team_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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