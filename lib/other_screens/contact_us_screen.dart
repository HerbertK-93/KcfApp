import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Physical Address\nLuteete Masooli\nP.O. Box 107722 Kampala',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telephone Contact',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () => launch('tel:+256706821115'),
                  child: const Text(
                    '0757 753 783',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
                InkWell(
                  onTap: () => launch('tel:+256771608016'),
                  child: const Text(
                    '0789 942 612',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email Contact',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () => launch('mailto:kingscogentfinance@gmail.com'),
                  child: const Text(
                    'kingscogentfinance@gmail.com',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
                InkWell(
                  onTap: () => launch('mailto:info@kingscogentfinance.com'),
                  child: const Text(
                    'info@kingscogentfinance.com',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Website',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () => launch('https://kingscogentfinance.com'), // Open company website URL
                  child: const Text(
                    'https://kingscogentfinance.com',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
