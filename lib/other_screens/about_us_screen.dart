// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABOUT KINGS COGENT FINANCE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kings Cogent Finance Limited was founded by three (3) members who saw the need to improve people’s livelihood in Kyadondo sub county and the country at large. Kings Cogent Finance Limited was established on 1st May 2022 and started operation in August 2022 to date.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR CORE VALUES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '- Team work\n- Integrity\n- Accountability and transparency\n- Effectiveness\n- Inclusion',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR VISION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Our vision is to create economic opportunities for the undeserved communities in Uganda and her neighbours by enabling access to flexible and affordable microfinance solutions.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR MISSION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Our mission is to empower individuals and contribute to the economic development of the region through microfinance. We believe in providing access to financial services and opportunities to the undeserved and marginalized populations, helping them build sustainable businesses, improve their livelihoods and create positive social-economic impact in their communities. Our commitment is to ensure financial inclusion, promote entrepreneurship and foster a culture of financial literacy and empowerment. By delivering personalized financial solutions, education and support, we aspire to break the cycle of poverty and creating a brighter future for the people of Uganda and neighboring regions.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
