import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    _totalSavings = _oneTimeAmount * (1 + _interestRate);
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
    double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    // Save user's information in Firestore
    FirebaseFirestore.instance.collection('once_plan').add({
      'one_time_amount': enteredAmount,
      'interest_rate': _interestRate,
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
