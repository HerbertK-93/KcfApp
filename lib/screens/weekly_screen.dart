import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklyScreen extends StatefulWidget {
  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late List<String> _selectedDays;
  double _weeklyDeposit = 0.0;
  double _interestRate = 0.12;
  double _totalSavings = 0.0;
  String _period = '';
  double _amount = 0;
  double _totalAmountWithInterest = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDefaults(); // Load saved defaults
  }

  void _loadDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDays = prefs.getStringList('selected_days') ?? ['Monday'];
      _period = prefs.getString('weekly_period') ?? '6 months';
      _amount = prefs.getDouble('weekly_amount') ?? 20.0;
      _weeklyDeposit = _amount;
      _calculateTotalSavings();
    });
  }

  void _saveDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selected_days', _selectedDays);
    prefs.setString('weekly_period', _period);
    prefs.setDouble('weekly_amount', _amount);
  }

  void _fetchDataAndUpdateUI() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('weekly_plan').doc('weekly_data').get();
      if (docSnapshot.exists) {
        setState(() {
          var userData = docSnapshot.data()!;
          _selectedDays = List<String>.from(userData['selected_days']);
          _weeklyDeposit = userData['weekly_deposit'] ?? 0.0;
          _interestRate = userData['interest_rate'] ?? 0.12;
          _period = userData['period'] ?? '6 months';
          _amount = userData['amount'] ?? 20;
          _calculateTotalSavings();
        });
      }
    } catch (error) {
      _showErrorDialog("Failed to fetch data: $error");
    }
  }

  void _calculateTotalSavings() {
    _totalSavings = 0.0;
    _totalAmountWithInterest = _amount * (1 + _interestRate);
    int numberOfWeeks = _getNumberOfWeeks();

    double principal = 0.0;
    for (int i = 0; i < numberOfWeeks; i++) {
      double interest = principal * _interestRate / 52;
      principal += _weeklyDeposit + interest;
      _totalSavings += principal;
    }
    setState(() {});
  }

  int _getNumberOfWeeks() {
    switch (_period) {
      case '6 months':
        return 26;
      case '1 year':
        return 52;
      case '1.5 years':
        return 78;
      case '2 years':
        return 104;
      default:
        return 0;
    }
  }

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
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _save();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    FirebaseFirestore.instance.collection('weekly_plan').doc('weekly_data').set({
      'selected_days': _selectedDays,
      'weekly_deposit': _weeklyDeposit,
      'interest_rate': _interestRate,
      'period': _period,
      'amount': _amount,
    }).then((value) {
      _saveDefaults();
      _fetchDataAndUpdateUI();
      print("Data saved successfully!");
    }).catchError((error) {
      _showErrorDialog("Failed to save data: $error");
    });
  }

  void _launchPaymentUrl() async {
    const url = 'https://flutterwave.com/pay/g3vpxdi0d3n8';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorDialog('Could not launch $url');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
                          _saveDefaults(); // Save selected days
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
                          _saveDefaults(); // Save period
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
                          _weeklyDeposit = _amount;
                          _calculateTotalSavings();
                          _saveDefaults(); // Save amount
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '12%', // Fixed interest rate
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount with Interest: \$${_totalAmountWithInterest.toStringAsFixed(2)}', // Show calculated amount with interest
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
