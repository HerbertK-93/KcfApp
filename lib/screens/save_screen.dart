import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/daily_screen.dart';
import 'package:kings_cogent/screens/emergency_fund.dart';
import 'package:kings_cogent/screens/land_acquisition.dart';
import 'package:kings_cogent/screens/medical_facilitation.dart';
import 'package:kings_cogent/screens/once_screen.dart';
import 'package:kings_cogent/screens/weekly_screen.dart';
import 'package:kings_cogent/screens/monthly_screen.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 4),
                child: Text(
                  'Saving Plans',
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
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 4),
                child: Text(
                  'Offers',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OfferCard(
                      title: 'Emergency Fund',
                      icon: Icons.health_and_safety_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyFundScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OfferCard(
                      title: 'Medical Facilitation',
                      icon: Icons.local_hospital_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicalFacilitationScreen(),
                          ),
                        );
                      },
                      centerTextBelowIcon: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              OfferCard(
                title: 'Land Acquisition',
                icon: Icons.landscape_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandAcquisitionScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
        leading: Icon(icon, size: 30, color: Colors.purple),
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
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
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

class OfferCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool centerTextBelowIcon;

  const OfferCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.centerTextBelowIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 8),
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  textAlign: centerTextBelowIcon ? TextAlign.center : TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
