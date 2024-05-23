import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnceScreen extends StatefulWidget {
  const OnceScreen({super.key});

  @override
  _OnceScreenState createState() => _OnceScreenState();
}

class _OnceScreenState extends State<OnceScreen> {
  late DateTime _selectedDate = DateTime.now();
  double _onceDeposit = 0.0;
  double _interestRate = 0.12; 
  double _totalSavings = 0.0; 
  String _period = '6 months'; 
  double _amount = 20; 
  double _calculatedAmount = 0.0; 
  final double _conversionRate = 3600; 
  List<Map<String, dynamic>> _transactionHistory = []; 

  @override
  void initState() {
    super.initState();
    _loadDefaults(); 
    _loadTransactionHistory(); 
  }

  void _loadDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
    });
  }

  void _loadTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('once_transaction_history');
    if (history != null) {
      setState(() {
        _transactionHistory = history.map((item) {
          Map<String, dynamic> transaction = {};
          List<String> details = item.split('|');
          transaction['day'] = details[0];
          transaction['amount'] = double.parse(details[1]);
          return transaction;
        }).toList();
      });
    }
  }

  void _saveTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = _transactionHistory.map((transaction) {
      return '${transaction['day']}|${transaction['amount']}';
    }).toList();
    await prefs.setStringList('once_transaction_history', history);
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
      principal += _onceDeposit + interest;
      _totalSavings += principal;
    }
    setState(() {}); 
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
    FirebaseFirestore.instance.collection('once_plan').add({
      'selected_day': _selectedDate,
      'one-time_deposit': _onceDeposit,
      'interest_rate': _interestRate,
      'period': _period,
      'amount': _amount,
    }).then((value) {
      _saveDefaults(); 

      setState(() {
        _transactionHistory.insert(0, { 
          'day': _selectedDate.toString().split(' ')[0],
          'amount': _amount,
        });
      });

      _saveTransactionHistory();
      _fetchDataAndUpdateUI();
    }).catchError((error) {
      // Handle errors
    });
  }

  void _fetchDataAndUpdateUI() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('once_plan').get();
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        setState(() {
          _selectedDate = (userData['selected_day'] as Timestamp).toDate();
          _onceDeposit = userData['once_deposit'] ?? 0.0;
          _interestRate = userData['interest_rate'] ?? 0.12; 
          _period = userData['period'] ?? '6 months'; 
          _amount = userData['amount'] ?? 20.0; 
          _calculateTotalSavings();
        });
      } else {
      }
    } catch (error) {
    }
  }

  void _launchPaymentUrl() async {
    const url = 'https://flutterwave.com/pay/g3vpxdi0d3n8';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
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
              const Text(
                'Select Day:',
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
                          _onceDeposit = _amount;
                          _calculateTotalSavings();
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 20,
                          child: Text('\$20 once (${(20 * _conversionRate).toStringAsFixed(2)} UGX)'),
                        ),
                        DropdownMenuItem(
                          value: 50,
                          child: Text('\$50 once (${(50 * _conversionRate).toStringAsFixed(2)} UGX)'),
                        ),
                        DropdownMenuItem(
                          value: 100,
                          child: Text('\$100 once (${(100 * _conversionRate).toStringAsFixed(2)} UGX)'),
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
                '12%', 
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'One-time returns: $_calculatedAmount USD (${(_calculatedAmount * _conversionRate).toStringAsFixed(2)} UGX)', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveWithConfirmation();
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
              const SizedBox(height: 16),
              const Text(
                'Transaction History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _transactionHistory.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactionHistory[index];
                    final onetimeReturns = transaction['amount'] + (transaction['amount'] * _interestRate);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text('Transaction ${_transactionHistory.length - index}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Day: ${transaction['day']}'),
                            Text('Amount: \$${transaction['amount']} (${(transaction['amount'] * _conversionRate).toStringAsFixed(2)} UGX)'),
                            Text('Onetime Returns: \$${onetimeReturns.toStringAsFixed(2)} (${(onetimeReturns * _conversionRate).toStringAsFixed(2)} UGX)'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
