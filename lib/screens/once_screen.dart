import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnceScreen extends StatefulWidget {
  @override
  _OnceScreenState createState() => _OnceScreenState();
}

class _OnceScreenState extends State<OnceScreen> {
  TextEditingController _amountController = TextEditingController();
  double _oneTimeAmount = 20.0; // Default one-time saving amount
  double _interestRate = 0.12; // Fixed interest rate (12%)
  double _totalSavings = 0.0; // Total savings accumulated over time
  List<Map<String, dynamic>>? _transactions; // Nullable transaction list

  @override
  void initState() {
    super.initState();
    // Load saved defaults
    _loadDefaults();
    // Initialize _transactions as an empty list
    _transactions = [];
  }

  // Function to load saved defaults
  void _loadDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _oneTimeAmount = prefs.getDouble('one_time_amount') ?? 20.0;
      _amountController.text = _oneTimeAmount.toString();
    });
    // Calculate total savings
    _calculateTotalSavings();
    // Fetch transaction history
    _fetchTransactionHistory();
  }

  // Function to calculate the total savings over time
  void _calculateTotalSavings() {
    double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    _totalSavings = enteredAmount * (1 + _interestRate);
    setState(() {}); // Update UI after calculating total savings
  }

  // Function to handle saving with confirmation dialog
  void _saveWithConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to save?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _save(); // Proceed with saving
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  // Function to handle saving
  void _save() async {
    double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    // Save user's information in Firestore
    FirebaseFirestore.instance.collection('once_plan').add({
      'one_time_amount': enteredAmount,
      'interest_rate': _interestRate,
    }).then((value) {
      // If saved successfully, fetch updated data and update UI
      _fetchDataAndUpdateUI();
      // Clear text field after saving
      _amountController.clear();
      print("Data saved successfully!");
    }).catchError((error) {
      // Handle errors
      print("Failed to save data: $error");
    });
  }

  // Function to fetch data from Firestore and update UI
  void _fetchDataAndUpdateUI() async {
    try {
      // Fetch user's information from Firestore
      final querySnapshot =
          await FirebaseFirestore.instance.collection('once_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the first document (assuming there's only one document)
        final userData = querySnapshot.docs.first.data();
        if (userData != null && userData is Map<String, dynamic>) {
          setState(() {
            // Update local variables with retrieved data
            _oneTimeAmount = userData['one_time_amount'] ?? 20.0; // Default amount option
            _interestRate = userData['interest_rate'] ?? 0.12; // Default to 12%
          });
        } else {
          print("Invalid user data format");
        }
      } else {
        print("No documents found in collection");
      }
    } catch (error) {
      // Handle errors
      print("Failed to fetch data: $error");
    }
  }

  // Function to launch payment URL
  void _launchPaymentUrl() async {
    const url = 'https://flutterwave.com/pay/g3vpxdi0d3n8';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  // Function to fetch transaction history
  void _fetchTransactionHistory() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('once_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> transactions = [];
        querySnapshot.docs.forEach((doc) {
          final data = doc.data();
          transactions.add({
            'one_time_amount': data['one_time_amount'] ?? 0,
            'totalAmountWithInterest': data['one_time_amount'] * (1 + _interestRate),
          });
        });
        setState(() {
          _transactions = transactions.reversed.toList(); // Reverse the order of transactions
        });
      }
    } catch (error) {
      print("Failed to fetch transaction history: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Time Plan'), // Updated title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Amount:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
                controller: _amountController,
                onChanged: (value) {
                  setState(() {
                    _calculateTotalSavings(); // Recalculate total savings when amount changes
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Interest Rate:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_interestRate * 100).toStringAsFixed(0)}%', // Display interest rate dynamically
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Display calculated amount
              Text(
                'One-time returns: \$${_totalSavings.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Save button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveWithConfirmation();
                        print("Save button pressed!");
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Review & Save',
                            style: TextStyle(fontSize: 16),
                          ),
                       
                      ),
                    ),
                  ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Payment button
              ElevatedButton(
                onPressed: _launchPaymentUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Tap here to initiate saving payment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Transaction history section
              const Text(
                'Transaction History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_transactions != null)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _transactions!.length,
                  itemBuilder: (context, index) {
                    // Determine background color based on system theme
                    Color? backgroundColor = Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[200] // Light theme background color
                        : const Color.fromARGB(255, 36, 35, 35); // Dark theme background color
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: backgroundColor,
                      ),
                      child: ListTile(
                        title: Text('Transaction ${index + 1}'), // Corrected
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('One-Time Amount: \$${_transactions![index]['one_time_amount']} (${(5000 * _transactions![index]['one_time_amount']).toStringAsFixed(0)} UGX)'),
                            Text('Total Amount With Interest: \$${_transactions![index]['totalAmountWithInterest'].toStringAsFixed(2)} (${(5000 * _transactions![index]['totalAmountWithInterest']).toStringAsFixed(0)} UGX)'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
