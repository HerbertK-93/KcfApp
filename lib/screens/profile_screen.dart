import 'package:flutter/material.dart';
import 'package:kings_cogent/widgets/user_transactionss_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');
      final String? username = prefs.getString('username');
      final String? bio = prefs.getString('bio');

      setState(() {
        userData = {
          'email': email,
          'username': username,
          'bio': bio,
        };
      });
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(193, 90, 201, 248),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(color: Colors.transparent, height: 0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.black26, // Change the color here
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userData['photoUrl'] ?? ''),
                    radius: 50,
                    child: const Icon(
                      Icons.person,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${userData['username'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildProfileField('Email', userData['email'] ?? '', context),
            const Divider(),
            _buildProfileField('Bio', userData['bio'] ?? '', context),
            const Divider(),
            _buildProfileField('UID', widget.uid, context),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserTransactionsPage()),
                  );
                },
                child: const Text(
                  'User Transactions',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KINGS COGENT FINANCE LTD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ],
    );
  }
}
