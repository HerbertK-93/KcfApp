import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AllTransactionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactionHistory;

  const AllTransactionsScreen({super.key, required this.transactionHistory});

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

  Future<void> _downloadTransactionHistory(BuildContext context) async {
    try {
      // Request storage permissions
      if (await _requestStoragePermission()) {
        // Generate CSV data
        List<List<dynamic>> rows = [];
        rows.add(["Date", "Amount (USD)", "Amount (UGX)", "Monthly Returns (USD)", "Monthly Returns (UGX)"]);

        for (var transaction in transactionHistory) {
          final date = transaction['date'];
          final amount = transaction['amount'];
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
        }

        String csvData = const ListToCsvConverter().convert(rows);

        // Get the Downloads directory
        final directory = await getExternalStorageDirectory();

        if (directory != null) {
          final path = "${directory.path}/transaction_history.csv";
          final file = File(path);
          await file.writeAsString(csvData);

          // Notify user of successful download
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaction history saved to $path")),
          );
        } else {
          // Notify user if directory is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to access storage directory")),
          );
        }
      } else {
        // Notify user of permission denial
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
    } catch (e) {
      // Notify user of an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save transaction history: $e")),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    print('Initial storage permission status: $status'); // Debug log

    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      status = await Permission.storage.request();
      print('Requested storage permission status: $status'); // Debug log
    }

    if (status.isGranted) {
      print('Storage permission granted'); // Debug log
      return true;
    } else {
      print('Storage permission not granted: $status'); // Debug log
      return false;
    }
  }
}
