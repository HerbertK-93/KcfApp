import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AllTransactionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> combinedHistory;

  const AllTransactionsScreen({super.key, required this.combinedHistory});

  @override
  Widget build(BuildContext context) {
    const conversionRate = 3600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await _downloadTransactionHistory(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: combinedHistory.length,
        itemBuilder: (context, index) {
          final item = combinedHistory[index];
          final date = item['date'];
          final amount = item['amount'];
          final type = item['type'];
          
          if (type == 'transaction') {
            const interestRate = 0.12;
            final monthlyReturns = amount + (amount * interestRate);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text('Transaction ${combinedHistory.length - index}'),
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
          } else if (type == 'deposit') {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text('Deposit ${combinedHistory.length - index}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $date'),
                    Text('Amount: $amount UGX'),
                  ],
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _downloadTransactionHistory(BuildContext context) async {
    try {
      if (await _requestStoragePermission()) {
        List<List<dynamic>> rows = [];
        rows.add(["Date", "Amount (USD)", "Amount (UGX)", "Monthly Returns (USD)", "Monthly Returns (UGX)"]);

        for (var item in combinedHistory) {
          final date = item['date'];
          final amount = item['amount'];
          final type = item['type'];
          if (type == 'transaction') {
            const interestRate = 0.12;
            const conversionRate = 3600;
            final monthlyReturns = amount + (amount * interestRate);
            rows.add([
              date,
              amount,
              (amount * conversionRate).toStringAsFixed(2),
              monthlyReturns.toStringAsFixed(2),
              (monthlyReturns * conversionRate).toStringAsFixed(2)
            ]);
          } else if (type == 'deposit') {
            rows.add([
              date,
              '',
              amount,
              '',
              ''
            ]);
          }
        }

        String csvData = const ListToCsvConverter().convert(rows);
        final directory = await getExternalStorageDirectory();

        if (directory != null) {
          final path = "${directory.path}/transaction_history.csv";
          final file = File(path);
          await file.writeAsString(csvData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaction history saved to $path")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to access storage directory")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save transaction history: $e")),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}
