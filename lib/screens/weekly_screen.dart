import 'package:KcfApp/providers/weekly_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late DateTime _selectedDate = DateTime.now();
  double _weeklyDeposit = 0.0;
  double _interestRate = 0.12;
  double _totalSavings = 0.0;
  String _period = '6 months';
  double _amount = 20;
  double _calculatedAmount = 0.0;
  final double _conversionRate = 3600;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  void _loadDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  void _saveDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_day', _selectedDate.toString());
    prefs.setDouble('amount', _amount);
  }

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
        _saveDefaults();
      });
    }
  }

  void _calculateTotalSavings() {
    _totalSavings = 0.0;
    _calculatedAmount = _amount + (_amount * _interestRate);

    int numberOfWeeks = _selectedDate.difference(DateTime.now()).inDays ~/ 7;

    double principal = 0.0;
    for (int i = 0; i < numberOfWeeks; i++) {
      double interest = principal * _interestRate / 52;
      principal += _weeklyDeposit + interest;
      _totalSavings += principal;
    }
    setState(() {});
  }

  void _saveAndPay() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm and Pay"),
          content: const Text("Do you want to save and pay?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      print('Confirmation received, proceeding to save transaction.');

      final provider = Provider.of<WeeklyProvider>(context, listen: false);

      await provider.saveTransactionToFirestore(
        _selectedDate,
        _weeklyDeposit,
        _interestRate,
        _period,
        _amount,
      );

      _saveDefaults();

      provider.addTransaction(
        _selectedDate.toString().split(' ')[0],
        _amount,
      );

      // Launch payment URL
      const url = 'https://flutterwave.com/pay/g3vpxdi0d3n8';
      if (await canLaunch(url)) {
        print('Launching payment URL.');
        await launch(url);
      } else {
        print('Could not launch $url');
      }
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
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Selected Day: ${_selectedDate.toString().split(' ')[0]}',
                      ),
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
                          _weeklyDeposit = _amount;
                          _calculateTotalSavings();
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 20,
                          child: Text('\$20 every week (${(20 * _conversionRate).toStringAsFixed(2)} UGX)'),
                        ),
                        DropdownMenuItem(
                          value: 50,
                          child: Text('\$50 every week (${(50 * _conversionRate).toStringAsFixed(2)} UGX)'),
                        ),
                        DropdownMenuItem(
                          value: 100,
                          child: Text('\$100 every week (${(100 * _conversionRate).toStringAsFixed(2)} UGX)'),
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
                '8%',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Weekly returns: $_calculatedAmount USD (${(_calculatedAmount * _conversionRate).toStringAsFixed(2)} UGX)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Save and pay button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAndPay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Save & Pay',
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
                'Transaction History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<WeeklyProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: provider.transactionHistory.length,
                      itemBuilder: (context, index) {
                        final transaction = provider.transactionHistory[index];
                        final weeklyReturns = transaction['amount'] + (transaction['amount'] * _interestRate);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text('Transaction ${provider.transactionHistory.length - index}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Day: ${transaction['day']}'),
                                Text('Amount: \$${transaction['amount']} (${(transaction['amount'] * _conversionRate).toStringAsFixed(2)} UGX)'),
                                Text('Weekly Returns: \$${weeklyReturns.toStringAsFixed(2)} (${(weeklyReturns * _conversionRate).toStringAsFixed(2)} UGX)'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                provider.deleteTransaction(index);
                              },
                            ),
                          ),
                        );
                      },
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