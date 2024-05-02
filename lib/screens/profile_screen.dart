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
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: userData?.photoUrl ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Icon(Icons.person, size: 100), // Placeholder Icon
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
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
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  _buildProfileField('Email', userData?.email ?? '', context),
                  const Divider(),
                  _buildProfileField('Bio', userData?.bio ?? '', context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildProfileField(String label, String value, BuildContext context) {
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
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ],
    );
  }
}
