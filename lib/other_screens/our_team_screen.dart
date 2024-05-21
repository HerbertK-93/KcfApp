import 'package:flutter/material.dart';

class OurTeamScreen extends StatelessWidget {
  const OurTeamScreen({super.key,});

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
              name: 'ISMAIL DEAN TENDO',
              position: 'Director',
              categories: 'Management',
              description:
                  'As the Director, Ismail oversees the overall strategic direction and management of the organization. With years of experience in leadership and management, Ismail is committed to driving innovation and achieving organizational goals.',
            ),
            const Divider(),
            _buildTeamMember(
              name: 'THOMAS LORATO',
              position: 'Director',
              categories: 'Management',
              description:
                  'Thomas supports the Director in implementing strategic plans and managing day-to-day operations. With a keen eye for detail and strong leadership skills, Thomas plays a crucial role in driving the organization forward.',
            ),
            const Divider(),
            _buildTeamMember(
              name: 'ERIC ONIEL LAKID',
              position: 'Operations Manager',
              categories: 'Management',
              description:
                  'A self-driven, forward-thinking individual focused on supporting cross-functional teams to increase productivity and client satisfaction, retain strong leadership and interpersonal skills so as to advance strategic plans and sales objectives set forth by management. Develop and implement policies to keep the organization’s budget low including operations, maintenance and labour costs but increasing productivity.',
            ),
            const Divider(),
            _buildTeamMember(
              name: 'AKITWI TEREZA',
              position: 'Branch Manager',
              categories: 'Management',
              description:
                  'I am an energetic, ambitious person who has developed a mature and responsible approach to any task that I undertake. As a graduate with over 4 years experience in management, I am excellent in working with others to achieve objectives. I also have the ability to work under pressure with minimal supervision. I am also comfortable in both solitary and group situations, and have excellent communication skills which are very useful in times of contact with the clients. I also have good observational and listening skills which are highly effective when interacting with both present and prospective clientele.',
            ),
            const Divider(),
            _buildTeamMember(
              name: 'HERBERT KISAJJAKI',
              position: 'IT Maintenance',
              categories: 'Technical',
              description:
                  'Herbert ensures the smooth functioning of our IT systems and infrastructure. With expertise in troubleshooting and maintenance, Herbert plays a vital role in ensuring the reliability and security of our digital operations.',
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
            const Icon(
              Icons.person,
              size: 100,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Position: $position\nCategories: $categories',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
