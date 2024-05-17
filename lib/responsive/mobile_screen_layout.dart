import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/daily_screen.dart';
import 'package:kings_cogent/screens/monthly_screen.dart';
import 'package:kings_cogent/screens/once_screen.dart';
import 'package:kings_cogent/screens/weekly_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kings_cogent/screens/profile_screen.dart';
import 'package:kings_cogent/widgets/sidebar.dart';

class SavingPlan {
  double amount;
  String frequency;
  double expectedReturns;

  SavingPlan({
    required this.amount,
    required this.frequency,
    required this.expectedReturns,
  });
}

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({Key? key});

  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: currentBrightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        title: const Text(''),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Text(
                'Saving Plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ServiceCard(
              title: 'Monthly',
              icon: Icons.calendar_today_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyScreen(),
                  ),
                );
              },
              isRecommended: true,
            ),
            const SizedBox(height: 4),
            ServiceCard(
              title: 'Weekly',
              icon: Icons.calendar_view_week_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            ServiceCard(
              title: 'Daily',
              icon: Icons.today_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            ServiceCard(
              title: 'Once',
              icon: Icons.calendar_view_day_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnceScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Dual Progress Bars for Savings Progress and Expected Returns
            const DualProgressBar(
              savingsProgress: 100, // Sample value for Savings Progress
              expectedReturns: 150, // Sample value for Expected Returns
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isRecommended;

  const ServiceCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Colors.blue,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
            ),
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(left: 70),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class DualProgressBar extends StatelessWidget {
  final double savingsProgress;
  final double expectedReturns;

  const DualProgressBar({
    required this.savingsProgress,
    required this.expectedReturns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressIndicator('Savings Progress', savingsProgress, Colors.green),
          SizedBox(height: 12),
          _buildProgressIndicator('Expected Returns', expectedReturns, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                value: value / 100,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                '${value.toInt()}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
