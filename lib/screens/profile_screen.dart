import 'package:flutter/material.dart';
import 'package:kings_cogent/models/user.dart';
import 'package:kings_cogent/resources/user_methods.dart';
import 'package:kings_cogent/utils/shared_prefs.dart';
import 'package:kings_cogent/widgets/user_details_page.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? appUser;

  @override
  void initState() {
    super.initState();
  }

  Stream<AppUser?> getUserProfile() {
    final userMethods = UserMethods(sharedPrefs: SharedPrefs());
    return Stream.fromFuture(userMethods.getUserProfile());
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
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(color: Colors.transparent, height: 0),
        ),
      ),
      body: StreamBuilder<AppUser?>(
          stream: getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final userData = snapshot.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 40.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey, // Change the color here
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.network(userData?.photoUrl ?? '',
                              width: 100, height: 100, fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          }),
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
                              userData?.username ?? '',
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
                  _buildProfileField('Email', userData?.email ?? '', context),
                  const Divider(),
                  _buildProfileField('Bio', userData?.bio ?? '', context),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to another page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserDetailsPage()),
                        );
                      },
                      child: const Text(
                        'User Details',
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
            );
          }),
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
