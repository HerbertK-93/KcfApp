import 'package:flutter/material.dart';

class AllTransactionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactionHistory;

  const AllTransactionsScreen({super.key, required this.transactionHistory});

  @override
  Widget build(BuildContext context) {
    const conversionRate = 3600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: ListView.builder(
        itemCount: transactionHistory.length,
        itemBuilder: (context, index) {
          final transaction = transactionHistory[index];
          final date = transaction['date'];
          final amount = transaction['amount'];
          const interestRate = 0.12;
          final monthlyReturns = amount + (amount * interestRate);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              title: Text('Transaction ${transactionHistory.length - index}'),
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
    );
  }
}
