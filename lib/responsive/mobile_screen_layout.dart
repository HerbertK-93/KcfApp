import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KcfApp/screens/profile_screen.dart';
import 'package:KcfApp/screens/save_screen.dart';
import 'package:KcfApp/screens/home_screen.dart';
import 'package:KcfApp/screens/deposit_screen.dart';  // Import DepositScreen
import 'package:KcfApp/screens/notification_screen.dart';
import 'package:KcfApp/widgets/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';  // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';  // For Firestore

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  _MobileScreenLayoutState createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;
  final PageController _pageController = PageController();

  // Page titles (Home, Deposit, Save, Profile)
  final List<String> _pageTitles = ["Home", "Deposit", "Save", "Profile"];

  double totalSavings = 0.0;  // Ensure this is set appropriately with your logic

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationsCount();
    _fetchTotalSavings(); // Ensure totalSavings is fetched here
  }

  void _fetchUnreadNotificationsCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _unreadNotifications = 0;
      });
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    setState(() {
      _unreadNotifications = querySnapshot.size;
    });
  }

  // Fetch the total savings
  void _fetchTotalSavings() async {
    // Add your logic to calculate total savings here
    setState(() {
      totalSavings = 10000;  // Replace with actual logic to calculate savings
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openNotificationScreen() {
    setState(() {
      _unreadNotifications = 0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()),
    ).then((_) {
      _fetchUnreadNotificationsCount();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge!.color;
    final iconColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: iconColor),
                onPressed: _openNotificationScreen,
                iconSize: 30,
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            onPressed: () async {
              const whatsappUrl = "https://wa.me/+256701936975";
              if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                await launchUrl(Uri.parse(whatsappUrl));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch WhatsApp')),
                );
              }
            },
            iconSize: 30,
          ),
        ],
      ),
      drawer: const SideBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // Correct order of screens in PageView
        children: const <Widget>[
          HomeScreen(),         // Home
          DepositScreen(),      // Deposit
          SaveScreen(),         // Save
          ProfileScreen(uid: ''),  // Profile
        ],
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.purple : textColor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings, color: _selectedIndex == 1 ? Colors.purple : textColor),
              label: 'Deposit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance, color: _selectedIndex == 2 ? Colors.purple : textColor),
              label: 'Save',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: _selectedIndex == 3 ? Colors.purple : textColor),  // Profile
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple,
          unselectedItemColor: textColor,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
