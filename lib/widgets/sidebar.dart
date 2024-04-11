import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/more.dart';
import 'package:kings_cogent/screens/settings_screen.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key); 

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
              color: Color.fromARGB(193, 90, 201, 248),
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
          const Divider(), // Add a divider here
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
}
