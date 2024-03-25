import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/more.dart';
import 'package:kings_cogent/screens/payment_options_screen.dart';
import 'package:kings_cogent/screens/settings_screen.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8, // Increase the width
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        children: <Widget>[
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
            ),
            child: const Center(
              child: Text(
                'MENU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const Divider(),
          _buildPaymentOptionsTile(context), // Add the payment options ListTile
          const Divider(),
          _buildListTileWithIcon(
            title: 'Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          _buildListTileWithIcon(
            title: 'More',
            icon: Icons.more_horiz,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoreScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTileWithIcon(
      {required String title,
      required IconData icon,
      required Function onTap}) {
    return ListTile(
      leading: Icon(icon), // Icon on the left side
      title: Text(title),
      onTap: () => onTap(),
      trailing: const Icon(Icons.arrow_forward), // Arrow icon on the right side
    );
  }

  // Method to build the ListTile for Payment Options
  Widget _buildPaymentOptionsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.payment), // Icon for payment options
      title: const Text('Payment Options'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentOptionsScreen()),
        );
      },
      trailing: const Icon(Icons.arrow_forward), // Arrow icon on the right side
    );
  }
}
