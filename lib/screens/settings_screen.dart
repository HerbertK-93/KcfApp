import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amberAccent,
      ),
      body: ListView(
        children: [
          _buildMenuItem(context, 'Share', () {
            _shareApp();
          }, Icons.share),
          const Divider(), // Divider between menu items
          _buildMenuItem(context, 'Logout', () {
            _confirmLogout(context);
          }, Icons.exit_to_app),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, Function() onTap, IconData icon) {
    return ListTile(
      title: Row(
        children: [
          Text(title),
          const Spacer(), // Add spacer to push the icon to the right
          GestureDetector(
            onTap: onTap,
            child: Icon(icon), // Add the icon wrapped in GestureDetector
          ),
        ],
      ),
    );
  }

  void _shareApp() async {
    const String message = 'Check out this awesome app!';
    const String url = 'https://example.com'; // Replace with your app link
    const String formattedMessage = '$message $url';

    if (await canLaunch('sms:?body=$formattedMessage')) {
      await launch('sms:?body=$formattedMessage');
    } else {
      throw 'Could not launch SMS';
    }
  }

  void _confirmLogout(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}
