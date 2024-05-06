import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklyScreen extends StatefulWidget {
  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  List<String> _selectedDays = ['Monday']; // Default selected days
  double _weeklyDeposit = 0.0;
  double _interestRate = 0.12; // Fixed interest rate (12%)
  double _totalSavings = 0.0; // Total savings accumulated over time
  String _period = '6 months'; // Default period option
  double _amount = 20; // Default amount option

  @override
  void initState() {
    super.initState();
    // Calculate total savings
    _fetchDataAndUpdateUI();
  }

  // Function to fetch data from Firestore and update UI
  void _fetchDataAndUpdateUI() async {
    try {
      // Fetch user's information from Firestore
      final querySnapshot = await FirebaseFirestore.instance.collection('weekly_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the first document (assuming there's only one document)
        final userData = querySnapshot.docs.first.data();
        if (userData != null && userData is Map<String, dynamic>) {
          setState(() {
            // Update local variables with retrieved data
            _weeklyDeposit = userData['weekly_deposit'] ?? 0.0;
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

  // Function to calculate the total savings over time
  void _calculateTotalSavings() {
    _totalSavings = 0.0; // Reset total savings
    int numberOfWeeks = _getNumberOfWeeks();

    double principal = 0.0; // Initial investment
    for (int i = 0; i < numberOfWeeks; i++) {
      double interest = principal * _interestRate / 52; // Assuming 52 weeks in a year
      principal += _weeklyDeposit + interest;
      _totalSavings += principal;
    }
    setState(() {}); // Update UI after calculating total savings
  }

  // Function to get the number of weeks based on selected period
  int _getNumberOfWeeks() {
    switch (_period) {
      case '6 months':
        return 26 * 6; // Approximate number of weeks in 6 months
      case '1 year':
        return 52; // Number of weeks in a year
      case '1.5 years':
        return 78; // Approximate number of weeks in 1.5 years
      case '2 years':
        return 104; // Approximate number of weeks in 2 years
      default:
        return 0;
    }
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
    FirebaseFirestore.instance.collection('weekly_plan').add({
      'weekly_deposit': _weeklyDeposit,
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
        title: const Text('Weekly Plan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Day of the Week:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Widget to select days of the week
              Wrap(
                spacing: 8.0,
                children: [
                  for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
                    ChoiceChip(
                      label: Text(day),
                      selected: _selectedDays.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                          _calculateTotalSavings();
                        });
                      },
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
                          child: Text('\$20 every week'),
                        ),
                        DropdownMenuItem(
                          value: 50,
                          child: Text('\$50 every week'),
                        ),
                        DropdownMenuItem(
                          value: 100,
                          child: Text('\$100 every week'),
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
