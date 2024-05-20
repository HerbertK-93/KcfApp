import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyScreen extends StatefulWidget {
  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  double _dailyDeposit = 0.0;
  double _interestRate = 0.12; // Fixed interest rate (12%)
  double _totalSavings = 0.0; // Total savings accumulated over time
  String _period = '6 months'; // Default period option
  double _amount = 20; // Default amount option
  double _totalAmountWithInterest = 0.0; // Amount after adding interest rate
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    // Load saved defaults
    _loadDefaults();
    // Calculate total savings
    _calculateTotalSavings();
    // Fetch transaction history
    _fetchTransactionHistory();
  }

  // Function to load saved defaults
  void _loadDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _period = prefs.getString('period') ?? '6 months';
      _amount = prefs.getDouble('amount') ?? 20.0;
      _dailyDeposit = _amount;
    });
  }

  // Function to save defaults
  void _saveDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('period', _period);
    prefs.setDouble('amount', _amount);
  }

  // Function to calculate the total savings over time
  void _calculateTotalSavings() {
    _totalSavings = 0.0; // Reset total savings
    _totalAmountWithInterest = _amount * (1 + _interestRate); // Calculate amount with interest

    int numberOfDays;
    if (_period == '6 months') {
      numberOfDays = 6 * 30;
    } else if (_period == '1 year') {
      numberOfDays = 12 * 30;
    } else if (_period == '1.5 years') {
      numberOfDays = (18 * 30).toInt();
    } else if (_period == '2 years') {
      numberOfDays = 24 * 30;
    } else {
      // Handle unexpected period
      return;
    }

    double principal = 0.0; // Initial investment
    for (int i = 0; i < numberOfDays; i++) {
      double interest = principal * _interestRate / 360;
      principal += _dailyDeposit + interest;
      _totalSavings += principal;
    }
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
  void _save() {
    // Save user's information in Firestore
    FirebaseFirestore.instance.collection('daily_plan').add({
      'daily_deposit': _dailyDeposit,
      'interest_rate': _interestRate,
      'period': _period,
      'amount': _amount,
    }).then((value) {
      // If saved successfully, fetch updated data and update UI
      _saveDefaults(); // Save defaults locally
      _fetchDataAndUpdateUI();
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
          await FirebaseFirestore.instance.collection('daily_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the first document (assuming there's only one document)
        final userData = querySnapshot.docs.first.data();
        if (userData != null && userData is Map<String, dynamic>) {
          setState(() {
            // Update local variables with retrieved data
            _dailyDeposit = userData['daily_deposit'] ?? 0.0;
            _interestRate = userData['interest_rate'] ?? 0.12; // Default to 12%
            _period = userData['period'] ?? '6 months'; // Default period option
            _amount = userData['amount'] ?? 20; // Default amount option
            // Calculate total savings based on retrieved data
            _calculateTotalSavings();
          });
          // Add transaction to history
          _addTransactionToHistory();
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

  // Function to add transaction to history
  void _addTransactionToHistory() {
    setState(() {
      _transactions.insert(
        0,
        {
          'amount': _amount,
          'totalAmountWithInterest': _totalAmountWithInterest,
        },
      );
    });
  }

  // Function to fetch transaction history
  void _fetchTransactionHistory() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('daily_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> transactions = [];
        querySnapshot.docs.forEach((doc) {
          final data = doc.data();
          transactions.add({
            'amount': data['amount'] ?? 0,
            'totalAmountWithInterest': data['daily_deposit'] * (1 + _interestRate),
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

  // Function to launch payment URL
  void _launchPaymentUrl() async {
    const url = 'https://flutterwave.com/pay/g3vpxdi0d3n8';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
 
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Daily Plan'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Period:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _period,
                    onChanged: (value) {
                      setState(() {
                        _period = value!;
                        _calculateTotalSavings();
                        _saveDefaults(); // Save selected period
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: '6 months',
                        child: Text('6 months'),
                      ),
                      DropdownMenuItem(
                        value: '1 year',
                        child: Text('1 year'),
                      ),
                      DropdownMenuItem(
                        value: '1.5 years',
                        child: Text('1.5 years'),
                      ),
                      DropdownMenuItem(
                        value: '2 years',
                        child: Text('2 years'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Amount:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<double>(
                    value: _amount,
                    onChanged: (value) {
                      setState(() {
                        _amount = value!;
                        _dailyDeposit = _amount; // Update daily deposit
                        _calculateTotalSavings();
                        _saveDefaults(); // Save selected amount
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 20,
                        child: Text('\$20 every day (${((5000 * 20)).toStringAsFixed(0)} UGX)'),
                      ),
                      DropdownMenuItem(
                        value: 50,
                        child: Text('\$50 every day (${((5000 * 50)).toStringAsFixed(0)} UGX)'),
                      ),
                      DropdownMenuItem(
                        value: 100,
                        child: Text('\$100 every day (${((5000 * 100)).toStringAsFixed(0)} UGX)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Interest Rate:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '12%', // Fixed interest rate
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Daily returns: \$${_totalAmountWithInterest.toStringAsFixed(0)} (${((5000 * _totalAmountWithInterest)).toStringAsFixed(0)} UGX)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                ),
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
ListView.builder(
  shrinkWrap: true,
  itemCount: _transactions.length,
  itemBuilder: (context, index) {
    // Determine background color based on system theme
    Color? backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[200] // Light theme background color
        : Color.fromARGB(255, 36, 35, 35); // Dark theme background color
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
      ),
      child: ListTile(
        title: Text('Transaction ${_transactions.length - index}'), // Corrected
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected Amount: \$${_transactions[index]['amount']} (${((5000 * _transactions[index]['amount'])).toStringAsFixed(0)} UGX)'),
            Text('Daily Returns: \$${_transactions[index]['totalAmountWithInterest'].toStringAsFixed(0)} (${((5000 * _transactions[index]['totalAmountWithInterest'])).toStringAsFixed(0)} UGX)'),
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