import 'dart:async';
import 'dart:ui'; // Import for ImageFilter

import 'package:flutter/material.dart';
import 'package:kings_cogent/models/user.dart';
import 'package:kings_cogent/resources/user_methods.dart';
import 'package:kings_cogent/utils/shared_prefs.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserMethods _userMethods;
  late SharedPrefs _sharedPrefs;
  late StreamController<AppUser?> _userStreamController;
  double _currentBalance = 0.0;
  bool _isBalanceVisible = true; // Flag to track the visibility of the balance

  @override
  void initState() {
    super.initState();
    _userMethods = UserMethods(sharedPrefs: SharedPrefs());
    _sharedPrefs = SharedPrefs();
    _userStreamController = StreamController<AppUser?>();
    _updateUserProfile();
    _calculateCurrentBalance();
  }

  @override
  void dispose() {
    _userStreamController.close();
    super.dispose();
  }

  void _updateUserProfile() {
    _userMethods.getUserProfile().then((user) {
      _userStreamController.add(user);
    });
  }

  Future<void> _calculateCurrentBalance() async {
    double monthlySavings = await _sharedPrefs.getMonthlySavings() ?? 0.0;
    double weeklySavings = await _sharedPrefs.getWeeklySavings() ?? 0.0;
    double dailySavings = await _sharedPrefs.getDailySavings() ?? 0.0;
    double oneTimeSavings = await _sharedPrefs.getOneTimeSavings() ?? 0.0;

    setState(() {
      _currentBalance =
          monthlySavings + weeklySavings + dailySavings + oneTimeSavings;
    });
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
    print('Building ProfileScreen...');
    final appBarTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appBarTextColor,
          ),
        ),
        backgroundColor: AppBarTheme.of(context).backgroundColor,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(color: Colors.transparent, height: 0),
        ),
      ),
      body: StreamBuilder<AppUser?>(
        stream: _userStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data;
          print('User Data Available: ${userData != null}');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userData?.photoUrl ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Icon(Icons.person, size: 100), // Placeholder Icon
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
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
                ),
                const SizedBox(height: 5),
                const Divider(),
                _buildProfileField(
                    'Email', userData?.email ?? '', context),
                const Divider(),
                _buildProfileField('Bio', userData?.bio ?? '', context),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: const AssetImage('assets/images/wave-bw.png'), // Path to your image asset
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                const Color.fromARGB(255, 35, 49, 35).withOpacity(0.7), // Fading effect
                                BlendMode.darken, // Adjust the blend mode as needed
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current Saving Balance',
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Text Color
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Column(
                                          children: [
                                            _isBalanceVisible
                                                ? Text(
                                                    '\$$_currentBalance',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white, // Text Color
                                                    ),
                                                  )
                                                : const Text(
                                                    'Coming Soon', // Placeholder text
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white, // Text Color
                                                    ),
                                                  ),
                                            const SizedBox(height: 5), // Adjust spacing if needed
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isBalanceVisible = !_isBalanceVisible;
                                      });
                                    },
                                    child: Icon(
                                      _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.white, // Icon Color
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(
      String label, String value, BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1!.color;
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
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ],
    );
  }
}
