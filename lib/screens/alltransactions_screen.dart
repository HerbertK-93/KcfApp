import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw; // PDF package for generating PDFs
import 'package:path_provider/path_provider.dart'; // For file storage
import 'package:permission_handler/permission_handler.dart'; // For handling permissions
import 'dart:io'; // For File IO

class AllTransactionsScreen extends StatelessWidget {
  final String transactionType; // either "deposit" or "monthly"

  const AllTransactionsScreen({Key? key, required this.transactionType}) : super(key: key);

  // Fetch all transactions based on the type (deposit or monthly)
  Stream<QuerySnapshot> _getAllTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transactions')
        .where('transaction_type', isEqualTo: transactionType)
        .snapshots();
  }

  // Format the date for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y, h:mm a').format(dateTime);
  }

  // Generate the PDF for download
  Future<void> _generatePdf(List<QueryDocumentSnapshot> transactions, BuildContext context) async {
    // Request storage permission
    if (await _requestStoragePermission()) {
      final pdf = pw.Document(); // Create a new PDF document

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  transactionType == 'deposit' ? 'All Deposits' : 'All Returns',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Amount', 'Currency', 'Status', 'Date'], // Headers
                    ...transactions.map((transaction) {
                      final transactionData = transaction.data() as Map<String, dynamic>;
                      final amount = transactionData['amount'].toString();
                      final currency = transactionData['currency'].toString();
                      final status = transactionData['status'].toString();
                      final date = DateTime.parse(transactionData['date']).toString();
                      return [amount, currency, status, date];
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF
      final downloadsDir = await _getDownloadsDirectory(); // Get the Downloads directory
      final file = File("${downloadsDir.path}/transactions_$transactionType.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to write to storage')),
      );
    }
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // Get the Downloads directory dynamically
  Future<Directory> _getDownloadsDirectory() async {
  if (Platform.isAndroid) {
    // On Android, we can either use the external files directory (app-specific)
    return await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
  } else if (Platform.isIOS) {
    // On iOS, only the app-specific documents directory is available
    return await getApplicationDocumentsDirectory();
  } else {
    throw UnsupportedError('Platform not supported');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transactionType == 'deposit' ? 'All Deposits' : 'All Returns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('transactions')
                  .where('transaction_type', isEqualTo: transactionType)
                  .get();

              if (snapshot.docs.isNotEmpty) {
                await _generatePdf(snapshot.docs, context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No transactions to export')),
                );
              }
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getAllTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index].data() as Map<String, dynamic>;
              final amount = transaction['amount'];
              final currency = transaction['currency'];
              final status = transaction['status'];
              final date = DateTime.parse(transaction['date']);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$currency $amount',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          _getStatusIcon(status),  // Status icon
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDateTime(date),
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: status == 'successful'
                                  ? Colors.green
                                  : (status == 'pending' ? Colors.orange : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Get the status icon based on transaction status
  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'failed':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }
}
