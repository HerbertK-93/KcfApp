import 'package:flutter/material.dart';
import 'package:kings_cogent/other_screens/loans_page.dart';
import 'package:kings_cogent/other_screens/savings_page.dart';

class UserTransactionsPage extends StatelessWidget {
  const UserTransactionsPage({Key? key}) : super(key: key); 

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
              // Navigate to LoansPage with arguments
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoansPage(
                    // Provide loan amount, start date, end date, and interest rate
                    loanAmount: 5000.0,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 30)),
                    interestRate: 10.0,
                    onLoanInfoConfirmed: (loanAmount, startDate, endDate, interestRate) {
                      // Define the callback function action here
                      // This function will be executed when loan information is confirmed
                      print('Loan information confirmed:');
                      print('Loan Amount: \$$loanAmount');
                      print('Start Date: $startDate');
                      print('End Date: $endDate');
                      print('Interest Rate: $interestRate%');
                    },
                  ),
                ),
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
              // Navigate to SavingsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavingsPage(
                  // Provide loan amount, start date, end date, and interest rate
                    savingsAmount: 5000.0,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 30)),
                    interestRate: 10.0,
                    onSavingsInfoConfirmed: (savingsAmount, startDate, endDate, interestRate) {
                      // Define the callback function action here
                      // This function will be executed when loan information is confirmed
                      print('Savings information confirmed:');
                      print('Savings Amount: \$$savingsAmount');
                      print('Start Date: $startDate');
                      print('End Date: $endDate');
                      print('Interest Rate: $interestRate%');
                    },
                )),
              );
            },
          ),
        ],
      ),
    );
  }
}
