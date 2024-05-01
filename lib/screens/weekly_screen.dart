import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyScreen extends StatefulWidget {
  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late DateTime _selectedDate;
  double _monthlyDeposit = 0.0;
  double _interestRate = 0.1; // Default interest rate (10%)
  List<double> _investmentData = []; // List to store investment growth data
  List<Map<String, dynamic>> _savedData = []; // List to store saved data
  List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

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
  Future<void> _selectDay(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _daysOfWeek.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_daysOfWeek[index]),
              onTap: () {
                setState(() {
                  _selectedDate = _getFirstDayOfWeek(index + 1); // Adjust index since DateTime starts from Monday as 1
                  _calculateInvestmentGrowth();
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
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

  // Function to load saved investment data from shared preferences
  Future<void> _loadInvestmentData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('investmentData')) {
      setState(() {
        _investmentData = prefs.getStringList('investmentData')!.map((e) => double.parse(e)).toList();
      });
    }
  }

  // Function to save investment data to shared preferences
  Future<void> _saveInvestmentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('investmentData', _investmentData.map((e) => e.toString()).toList());
  }

  // Function to save the selected date, monthly deposit, and interest rate
  void _saveData() {
    // Save the selected date, monthly deposit, and interest rate
    Map<String, dynamic> data = {
      'Date': _selectedDate,
      'Monthly Deposit': _monthlyDeposit,
      'Interest Rate': _interestRate,
    };
    _savedData.add(data);
  }

  // Function to get the first day of the week based on index (1-7)
  DateTime _getFirstDayOfWeek(int dayIndex) {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    int difference = dayIndex - currentDay;
    if (difference <= 0) difference += 7;
    return now.add(Duration(days: difference - 7));
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
                      child: Text('Selected Day: ${_daysOfWeek[_selectedDate.weekday - 1]}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Weekly Deposit:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter weekly deposit amount',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _monthlyDeposit = double.tryParse(value) ?? 0.0;
                    _calculateInvestmentGrowth();
                    _saveInvestmentData();
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
                          _saveInvestmentData();
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
                        _saveData();
                        setState(() {
                          // Clear the investment data to reflect the changes
                          _investmentData.clear();
                          // Recalculate investment growth after saving data
                          _calculateInvestmentGrowth();
                        });
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
                                title: Text('Week ${index + 1}'),
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

