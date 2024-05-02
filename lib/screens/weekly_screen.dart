import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyScreen extends StatefulWidget {
  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late String _selectedDay;
  double _monthlyDeposit = 0.0;
  double _interestRate = 0.1; // Default interest rate (10%)
  List<double> _investmentData = []; // List to store investment growth data
  List<Map<String, dynamic>> _savedData = []; // List to store saved data
  List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    // Initialize selected day to Monday
    _selectedDay = _daysOfWeek[0];
    // Load saved investment data
    _loadInvestmentData();
    // Initial calculation
    _calculateInvestmentGrowth();
  }

  // Function to update the selected day
  Future<void> _selectDay(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
          child: ListView.builder(
            itemCount: _daysOfWeek.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_daysOfWeek[index]),
                onTap: () {
                  setState(() {
                    _selectedDay = _daysOfWeek[index];
                    _calculateInvestmentGrowth();
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  // Function to load investment data from Firestore
  void _loadInvestmentData() {
    // Assuming the collection in Firestore is named 'weekly_plan'
    FirebaseFirestore.instance.collection('weekly_plan').get().then((querySnapshot) {
      // Clear the investment data list before adding new data
      _investmentData.clear();
      // Iterate through the documents
      querySnapshot.docs.forEach((doc) {
        // Extract the investment amount from each document
        dynamic investmentValue = doc.data()['investment'];
        // Check if investmentValue is not null and is of type double
        if (investmentValue != null && investmentValue is double) {
          double investment = investmentValue;
          // Add the investment amount to the list
          _investmentData.add(investment);
        }
      });
      // After loading data, recalculate investment growth
      _calculateInvestmentGrowth();
    }).catchError((error) {
      // Handle errors
      print("Failed to load investment data: $error");
    });
  }

  // Function to calculate investment growth (Simulated function)
  void _calculateInvestmentGrowth() {
    // Simulated function for calculating investment growth
  }

  // Function to handle saving with confirmation dialog
  void _saveWithConfirmationDialog() {
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

  // Function to handle saving (Simulated function)
  void _save() {
    // Save data to Firestore
    FirebaseFirestore.instance.collection('weekly_plan').add({
      'selected_day': _selectedDay,
      'monthly_deposit': _monthlyDeposit,
      'interest_rate': _interestRate,
    }).then((value) {
      // If saved successfully, reload investment data
      _loadInvestmentData();
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
                'Select Start Day:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDay(context),
                      child: Text('Selected Day: $_selectedDay'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Monthly Deposit:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter monthly deposit amount',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _monthlyDeposit = double.tryParse(value) ?? 0.0;
                    _calculateInvestmentGrowth();
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
                          _calculateInvestmentGrowth();
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
              const SizedBox(height: 16),
              // Save button
Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          _saveWithConfirmationDialog();
          print("Save button pressed!");
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
                child: AnimatedProgressIndicator(totalSavings: _investmentData),
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
  final List<double> totalSavings;

  const AnimatedProgressIndicator({Key? key, required this.totalSavings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxTotalSavings = totalSavings.isNotEmpty ? totalSavings.reduce((a, b) => a > b ? a : b) : 0.0;
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
            width: maxTotalSavings * MediaQuery.of(context).size.width / 1000,
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
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$0'),
                  Text('\$1000'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
