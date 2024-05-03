import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MonthlyScreen extends StatefulWidget {
  @override
  _MonthlyScreenState createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late DateTime _selectedDate;
  double _monthlyDeposit = 0.0;
  double _interestRate = 0.12; // Fixed interest rate (12%)
  double _totalSavings = 0.0; // Total savings accumulated over time
  String _period = '6 months'; // Default period option
  double _amount = 20; // Default amount option

  @override
  void initState() {
    super.initState();
    // Initialize selected date to the current date
    _selectedDate = DateTime.now();
    // Calculate total savings
    _fetchDataAndUpdateUI();
  }

  // Function to fetch data from Firestore and update UI
  void _fetchDataAndUpdateUI() async {
    try {
      // Fetch user's information from Firestore
      final querySnapshot = await FirebaseFirestore.instance.collection('monthly_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the first document (assuming there's only one document)
        final userData = querySnapshot.docs.first.data();
        if (userData != null && userData is Map<String, dynamic>) {
          setState(() {
            // Update local variables with retrieved data
            _selectedDate = (userData['selected_date'] as Timestamp).toDate();
            _monthlyDeposit = userData['monthly_deposit'] ?? 0.0;
            _interestRate = userData['interest_rate'] ?? 0.12; // Default to 12%
            _period = userData['period'] ?? '6 months'; // Default period option
            _amount = userData['amount'] ?? 20; // Default amount option
            // Calculate total savings based on retrieved data
            _calculateTotalSavings();
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

  // Function to update the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateTotalSavings();
      });
    }
  }

  // Function to calculate the total savings over time
  void _calculateTotalSavings() {
    _totalSavings = 0.0; // Reset total savings
    int numberOfMonths = _selectedDate.year * 12 +
        _selectedDate.month -
        (DateTime.now().year * 12 + DateTime.now().month);

    double principal = 0.0; // Initial investment
    for (int i = 0; i < numberOfMonths; i++) {
      double interest = principal * _interestRate / 12;
      principal += _monthlyDeposit + interest;
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
    FirebaseFirestore.instance.collection('monthly_plan').add({
      'selected_date': _selectedDate,
      'monthly_deposit': _monthlyDeposit,
      'interest_rate': _interestRate,
      'period': _period,
      'amount': _amount,
    }).then((value) {
      // If saved successfully, fetch updated data and update UI
      _fetchDataAndUpdateUI();
      print("Data saved successfully!");
    }).catchError((error) {
      // Handle errors
      print("Failed to save data: $error");
    });
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
        title: const Text('Monthly Plan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Start Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                          'Selected Date: ${_selectedDate.toString().split(' ')[0]}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                          _calculateTotalSavings();
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 20,
                          child: Text('\$20 every month'),
                        ),
                        DropdownMenuItem(
                          value: 50,
                          child: Text('\$50 every month'),
                        ),
                        DropdownMenuItem(
                          value: 100,
                          child: Text('\$100 every month'),
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
              const Text(
                'Investment Growth Over Time:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                child: AnimatedProgressIndicator(totalSavings: _totalSavings),
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
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedProgressIndicator extends StatelessWidget {
  final double totalSavings;

  const AnimatedProgressIndicator({Key? key, required this.totalSavings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width * totalSavings / 10000,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 4,
                color: Colors.white,
              ),
            ),
          ),
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$0'),
                  Text('\$10000'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
