import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class OnceScreen extends StatefulWidget {
  @override
  _OnceScreenState createState() => _OnceScreenState();
}

class _OnceScreenState extends State<OnceScreen> {
  double _onceDeposit = 0.0;
  double _interestRate = 0.1; // Default interest rate (10%)
  double _totalSavings = 0.0; // Total savings accumulated over time

  @override
  void initState() {
    super.initState();
    // Fetch data from Firestore and update UI
    _fetchDataAndUpdateUI();
  }

  // Function to fetch data from Firestore and update UI
  void _fetchDataAndUpdateUI() async {
    try {
      // Fetch user's information from Firestore
      final DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('one-time_plan').doc('user_data').get();
      if (documentSnapshot.exists) {
        final userData = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _onceDeposit = userData['one-time_deposit'];
          _interestRate = userData['interest_rate'];
          _calculateTotalSavings();
        });
      }
    } catch (error) {
      print("Failed to fetch data: $error");
    }
  }

  // Function to calculate the total savings over time
  void _calculateTotalSavings() {
    _totalSavings = 0.0; // Reset total savings
    int numberOfDays = DateTime.now().difference(DateTime(2024, 5, 1)).inDays;

    double principal = 0.0; // Initial investment
    for (int i = 0; i < numberOfDays; i++) {
      double interest = principal * _interestRate / 365;
      principal += _onceDeposit + interest;
      _totalSavings += principal;
    }
    setState(() {}); // Update UI after calculating total savings
  }

  // Function to handle saving user data to Firestore
  Future<void> _saveUserDataToFirestore() async {
    // Show confirmation dialog before saving
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Are you sure want to save?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when user clicks No
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when user clicks Yes
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      try {
        await FirebaseFirestore.instance.collection('one-time_plan').doc('user_data').set({
          'one-time_deposit': _onceDeposit,
          'interest_rate': _interestRate,
        });
        print("User data saved successfully!");
      } catch (error) {
        print("Failed to save user data: $error");
      }
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
        title: const Text('One-time Plan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'One-time Deposit:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter one-time deposit amount',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _onceDeposit = double.tryParse(value) ?? 0.0;
                    _calculateTotalSavings();
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Interest Rate:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<double>(
                      value: _interestRate,
                      onChanged: (value) {
                        setState(() {
                          _interestRate = value!;
                          _calculateTotalSavings();
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 0.1,
                          child: Text('10%'),
                        ),
                        DropdownMenuItem(
                          value: 0.15,
                          child: Text('15%'),
                        ),
                        DropdownMenuItem(
                          value: 0.2,
                          child: Text('20%'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Save button
              ElevatedButton(
                onPressed: () {
                  // Save user data to Firestore
                  _saveUserDataToFirestore();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded edges
                  ),
                ),
                child: const SizedBox(
                  width: double.infinity, // Stretch horizontally to the edges of the screen
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                    borderRadius: BorderRadius.circular(10), // Rounded edges
                  ),
                ),
                child: const SizedBox(
                  width: double.infinity, // Stretch horizontally to the edges of the screen
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

  const AnimatedProgressIndicator({Key? key, required this.totalSavings}) : super(key: key);

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
            width: MediaQuery.of(context).size.width * totalSavings / 1000,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 4, // Width of the vertical bar
                color: Colors.white, // Color of the vertical bar
              ),
            ),
          ),
        ],
      ),
    );
  }
}
