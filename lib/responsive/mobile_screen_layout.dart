// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kings_cogent/screens/agricultural_loan.dart';
import 'package:kings_cogent/screens/business_loan.dart';
import 'package:kings_cogent/screens/emergency_loan.dart';
import 'package:kings_cogent/screens/personal_loan.dart';
import 'package:kings_cogent/screens/profile_screen.dart';
import 'package:kings_cogent/screens/salary_loan_screen.dart';
import 'package:kings_cogent/screens/school_fees_loan_screen.dart';
import 'package:kings_cogent/widgets/sidebar.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(193, 90, 201, 248),
        title: const Text(
          'KINGS COGENT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'MadimiOne-Regular',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(
                    uid: '',
                  ),
                ),
              );
            },
            iconSize: 30,
          ),
        ],
      ),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(8, 16, 8, 8), // Reduced padding
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SizedBox(width: 8),
                    HorizontalCard(
                      title: 'Loan Balance',
                      balance: '\$5000', // Sample loan balance
                      color: Color.fromARGB(255, 175, 139, 76),
                      width: 300,
                    ),
                    SizedBox(width: 8),
                    HorizontalCard(
                      title: 'Savings Balance',
                      balance: '\$1000', // Sample savings balance
                      color: Color.fromARGB(255, 243, 33, 100),
                      width: 300,
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 1, 0, 1), // Moved "Our Services" to the left
              child: Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              childAspectRatio: 1.2,
              children: [
                LoanTile(
                  title: 'School Fees Loans',
                  imagePath: 'assets/images/school.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchoolFeesLoanScreen(),
                      ),
                    );
                  },
                ),
                LoanTile(
                  title: 'Salary Loans',
                  imagePath: 'assets/images/money.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalaryLoanScreen(),
                      ),
                    );
                  },
                ),
                LoanTile(
                  title: 'Emergency Loans',
                  imagePath: 'assets/images/emergency.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyLoanScreen(),
                      ),
                    );
                  },
                ),
                LoanTile(
                  title: 'Personal Loans',
                  imagePath: 'assets/images/personal loan.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalLoanScreen(),
                      ),
                    );
                  },
                ),
                LoanTile(
                  title: 'Agricultural Loans',
                  imagePath: 'assets/images/tractor.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgriculturalLoanScreen(),
                      ),
                    );
                  },
                ),
                LoanTile(
                  title: 'Business Loans',
                  imagePath: 'assets/images/business.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessLoanScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Talk to us'),
                content: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Subject',
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Your Email',
                        ),
                      ),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Your Message',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'kingscogentfinance@gmail.com',
                        queryParameters: {
                          'subject': 'Subject',
                          'body': 'Your message here.'
                        },
                      );
                      final String urlString = emailLaunchUri.toString();
                      if (await canLaunch(urlString)) {
                        await launch(urlString);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your message has been sent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        throw 'Could not launch $urlString';
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.purple.shade200,
        elevation: 20,
        child: const Icon(Icons.chat_bubble),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class HorizontalCard extends StatefulWidget {
  final String title;
  final String balance;
  final Color color;
  final double width;

  const HorizontalCard({
    super.key,
    required this.title,
    required this.balance,
    required this.color,
    required this.width,
  });

  @override
  _HorizontalCardState createState() => _HorizontalCardState();
}

class _HorizontalCardState extends State<HorizontalCard> {
  bool showBalance = true;

  @override
  Widget build(BuildContext context) {
    // Sample start date and duration (in days) for demonstration purposes
    DateTime startDate = DateTime.now();
    int duration = 30; // Duration in days

    // Calculate the end date
    DateTime endDate = startDate.add(Duration(days: duration));

    // Calculate the number of days left
    int daysLeft = max(0, endDate.difference(DateTime.now()).inDays);

    String currentDate = DateFormat.yMd().format(DateTime.now());
    String periodLeft = '$daysLeft days left';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage('assets/images/card background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 28, 53, 26),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showBalance = !showBalance;
                          });
                        },
                        icon: Icon(
                          showBalance ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showBalance ? widget.balance : '****',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentDate,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        periodLeft, // Show the number of days left
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const LoanTile({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8), // Increased padding here
            Padding(
              padding:
                  const EdgeInsets.all(8.0), // Added padding around the text
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
