import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/daily_screen.dart';
import 'package:kings_cogent/screens/monthly_screen.dart';
import 'package:kings_cogent/screens/once_screen.dart';
import 'package:kings_cogent/screens/weekly_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kings_cogent/screens/profile_screen.dart';
import 'package:kings_cogent/widgets/sidebar.dart';
import 'package:fl_chart/fl_chart.dart';

class SavingPlan {
  double amount;
  String frequency;
  double expectedReturns;

  SavingPlan({required this.amount, required this.frequency, required this.expectedReturns});
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 1, 0, 1),
              child: Text(
                'Saving plans',
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
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
              padding: const EdgeInsets.all(8),
              childAspectRatio: 1.4,
              children: [
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
                ),
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
              ],
            ),
            const SizedBox(height: 20),
            // Graph for Savings Progress
            const GraphWidget(
              title: 'Savings Progress',
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isBlueIcon = title == 'Monthly' || title == 'Weekly' || title == 'Daily' || title == 'Once';

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: isBlueIcon ? Colors.blue : Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                  ),
                ],
              ),
              if (isBlueIcon && title == 'Monthly')
                Positioned(
                  top: 0,
                  left: 0,
                  right: 100,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Recommended',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphWidget extends StatelessWidget {
  final String title;
  final double savingsProgress;
  final double expectedReturns;

  const GraphWidget({
    required this.title,
    required this.savingsProgress,
    required this.expectedReturns,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: savingsProgress,
                      title: '\$${savingsProgress.toInt()}',
                      color: Colors.red, // Color for Savings Progress
                    ),
                    PieChartSectionData(
                      value: expectedReturns,
                      title: '\$${expectedReturns.toInt()}',
                      color: Colors.blue, // Color for Expected Returns
                    ),
                  ],
                  centerSpaceRadius: 100,
                  sectionsSpace: 0,
                  startDegreeOffset: 200,
                ),
              ),
            ),
            // Key for representing the colors
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 20,
                  height: 20,
                  color: Colors.red,
                ),
                const Text('Progress'),
                const SizedBox(width: 20),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 20,
                  height: 20,
                  color: Colors.blue,
                ),
                const Text('Returns'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
