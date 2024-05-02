// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class OurTeamScreen extends StatelessWidget {
  const OurTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamMember(
              name: 'ERIC ONIEL LAKID',
              position: 'Operations Manager',
              categories: 'Management',
              description:
                  'A self-driven, forward-thinking individual focused on supporting cross-functional teams to increase productivity and client satisfaction, retain strong leadership and interpersonal skills so as to advance strategic plans and sales objectives set forth by management. Develop and implement policies to keep the organization’s budget low including operations, maintenance and labour costs but increasing productivity.',
            ),
            Divider(),
            _buildTeamMember(
              name: 'AKITWI TEREZA',
              position: 'Branch Manager',
              categories: 'Management',
              description:
                  'I am an energetic, ambitious person who has developed a mature and responsible approach to any task that I undertake. As a graduate with over 4 years experience in management, I am excellent in working with others to achieve objectives. I also have the ability to work under pressure with minimal supervision. I am also comfortable in both solitary and group situations, and have excellent communication skills which are very useful in times of contact with the clients. I also have good observational and listening skills which are highly effective when interacting with both present and prospective clientele.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String position,
    required String categories,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: 100,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Position: $position\nCategories: $categories',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
