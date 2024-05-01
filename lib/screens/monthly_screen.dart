import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyScreen extends StatefulWidget {
  @override
  _MonthlyScreenState createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late DateTime _selectedDate;
  double _monthlyDeposit = 0.0;
  double _interestRate = 0.1; // Default interest rate (10%)
  List<double> _investmentData = []; // List to store investment growth data

  @override
  void initState() {
    super.initState();
    // Initialize selected date to the current date
    _selectedDate = DateTime.now();
    // Load saved investment data
    _loadInvestmentData();
    // Initial calculation
    _calculateInvestmentGrowth();
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
        _calculateInvestmentGrowth();
      });
    }
  }

  // Function to calculate the investment growth over time
  void _calculateInvestmentGrowth() {
    _investmentData.clear();
    double principal = 0.0; // No initial investment
    int numberOfMonths = DateTime.now().difference(_selectedDate).inDays ~/ 30;

    for (int i = 0; i < numberOfMonths; i++) {
      double interest = principal * _interestRate / 12;
      principal += _monthlyDeposit + interest;
      _investmentData.add(principal);
    }
  }

  // Function to load saved investment data from Firestore
  Future<void> _loadInvestmentData() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('monthly_saving_plans').doc('1').get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _selectedDate = data['date'].toDate();
        _monthlyDeposit = data['monthlyDeposit'];
        _interestRate = data['interestRate'];
        _calculateInvestmentGrowth();
      });
    }
  }

  // Function to save investment data to Firestore
  Future<void> _saveInvestmentData() async {
    await FirebaseFirestore.instance.collection('monthly_saving_plans').doc('1').set({
      'date': _selectedDate,
      'monthlyDeposit': _monthlyDeposit,
      'interestRate': _interestRate,
    });
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
                      child: Text('Selected Date: ${_selectedDate.toString().split(' ')[0]}'),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveInvestmentData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Changes saved successfully')),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Investment Growth Over Time:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 300,
                    child: _investmentData.isEmpty
                        ? const Center(child: Text('No data available'))
                        : ListView.builder(
                            itemCount: _investmentData.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('Month ${index + 1}'),
                                subtitle: Text('\$${_investmentData[index].toStringAsFixed(2)}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
