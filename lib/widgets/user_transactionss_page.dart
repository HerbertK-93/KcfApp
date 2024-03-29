import 'package:flutter/material.dart';
import 'package:kings_cogent/other_screens/loans_page.dart';
import 'package:kings_cogent/other_screens/savings_page.dart';

class UserTransactionsPage extends StatelessWidget {
  const UserTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Transactions'),
        elevation: 4, // Adding elevation to the app bar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.monetization_on), // Better icon for Loans
                SizedBox(width: 16),
                Text('Loans'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward), // Trailing arrow
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoansPage()),
              );
            },
          ),
          const Divider(), // Divider between Loans and Savings
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.account_balance), // Icon for Savings
                SizedBox(width: 16),
                Text('Savings'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward), // Trailing arrow
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
