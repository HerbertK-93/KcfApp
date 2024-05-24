import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/alltransactions_screen.dart';
import 'package:kings_cogent/screens/daily_screen.dart';
import 'package:kings_cogent/screens/once_screen.dart';
import 'package:kings_cogent/screens/weekly_screen.dart';
import 'package:provider/provider.dart';
import 'package:kings_cogent/screens/monthly_screen.dart';
import 'package:kings_cogent/screens/profile_screen.dart';
import 'package:kings_cogent/widgets/sidebar.dart';
import 'package:kings_cogent/providers/transaction_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final conversionRate = 3600;
    final totalReturnsUGX = (transactionProvider.totalMonthlyReturns * conversionRate).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(uid: ''),
                ),
              );
            },
            iconSize: 30,
          ),
        ],
      ),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
                child: Text(
                  'Total Returns',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(0),
                child: Center(
                  child: Text(
                    '\$${transactionProvider.totalMonthlyReturns.toStringAsFixed(2)} USD ($totalReturnsUGX UGX)',
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 175, 107, 76)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
                child: Text(
                  'Saving Plan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              ServiceCard(
                title: 'Monthly',
                icon: Icons.calendar_today_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MonthlyScreen(),
                    ),
                  );
                },
                isRecommended: true,
              ),
              ServiceCard(
                title: 'Weekly',
                icon: Icons.calendar_view_week_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeeklyScreen(),
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
                      builder: (context) => const DailyScreen(),
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
                      builder: (context) => const OnceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const FinancialTipsCarousel(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transactions:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllTransactionsScreen(transactionHistory: transactionProvider.transactionHistory),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 182, 109, 195)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              transactionProvider.transactionHistory.isEmpty
                  ? const Center(child: Text('No transactions found'))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactionProvider.transactionHistory.length,
                      itemBuilder: (context, index) {
                        final transaction = transactionProvider.transactionHistory[index];
                        final date = transaction['date'];
                        final amount = transaction['amount'];
                        final monthlyReturns = amount + (amount * 0.12);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text('Transaction ${transactionProvider.transactionHistory.length - index}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: $date'),
                                Text('Amount: \$$amount (${(amount * conversionRate).toStringAsFixed(2)} UGX)'),
                                Text('Monthly Returns: \$${monthlyReturns.toStringAsFixed(2)} (${(monthlyReturns * conversionRate).toStringAsFixed(2)} UGX)'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
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
                      TextField(decoration: InputDecoration(labelText: 'Your Name')),
                      TextField(decoration: InputDecoration(labelText: 'Subject')),
                      TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Your Email')),
                      TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Your Message')),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'kingscogentfinance@gmail.com',
                        queryParameters: {'subject': 'Subject', 'body': 'Your message here.'},
                      );
                      final String urlString = emailLaunchUri.toString();
                      if (await canLaunch(urlString)) {
                        await launch(urlString);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your message has been sent!'), duration: Duration(seconds: 2)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  final bool isRecommended;

  const ServiceCard({
    super.key,
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
        leading: Icon(icon, size: 30, color: Colors.purple.shade200),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(left: 80),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  'Recommended',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 203, 117, 218)),
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

class FinancialTipsCarousel extends StatelessWidget {
  const FinancialTipsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(height: 100, autoPlay: true, enlargeCenterPage: true),
      items: [
        'Coming soon -> ',
        'Web version',
        'Loans with good interest rates',
        'Emergency fund',
        'Kings Cogent visa Card',
        'Kings Cogent mobile wallet',
        'Financial Benefits and Incentives',
        'Awards to our best customers',
        'And much more!',
      ].map((tip) {
        return Container(
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 74, 69, 74) : const Color.fromARGB(255, 73, 63, 73),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
