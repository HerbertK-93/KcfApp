import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({Key? key}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> loanHistory = [];
  List<String> savingsHistory = [];
  List<String> transactionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadLoanHistory();
    _loadSavingsHistory();
    _loadTransactionHistory();
  }

  Future<void> _loadLoanHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loanHistory = prefs.getStringList('loanHistory') ?? [];
    });
  }

  Future<void> _saveLoanHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('loanHistory', loanHistory);
  }

  Future<void> _loadSavingsHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savingsHistory = prefs.getStringList('savingsHistory') ?? [];
    });
  }

  Future<void> _saveSavingsHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savingsHistory', savingsHistory);
  }

  Future<void> _loadTransactionHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      transactionHistory = prefs.getStringList('transactionHistory') ?? [];
    });
  }

  Future<void> _saveTransactionHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('transactionHistory', transactionHistory);
  }

  Future<void> _selectDate(BuildContext context, String title, bool isStartDate,
      [bool? isLoan]) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('$title: ${DateFormat('yyyy-MM-dd').format(pickedDate)}'),
        ),
      );
      setState(() {
        if (_startDate == null || isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
          transactionHistory.add(
              '${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}');
          _startDate = null;
          _endDate = null;
          _saveTransactionHistory();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Loans History'),
              Tab(text: 'Savings History'),
              Tab(text: 'Transaction History'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: [
                _buildLoanHistoryTab(context),
                _buildSavingsHistoryTab(context),
                _buildTransactionHistoryTab(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanHistoryTab(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context, 'Loan Start Date', true),
              child: const Text('Select Loan Start Date'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, 'Loan End Date', false),
              child: const Text('Select Loan End Date'),
            ),
          ],
        ),
        if (loanHistory.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.builder(
                itemCount: loanHistory.length ~/ 2,
                itemBuilder: (context, index) {
                  final int startIndex = index * 2;
                  final String startDate = loanHistory[startIndex];
                  final String endDate = loanHistory[startIndex + 1];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Start Date: $startDate',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        subtitle: Text(
                          'End Date: $endDate',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              loanHistory.removeAt(startIndex);
                              loanHistory.removeAt(startIndex);
                              _saveLoanHistory();
                            });
                          },
                        ),
                      ),
                      if (index != loanHistory.length ~/ 2 - 1) const Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSavingsHistoryTab(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, 'Savings Start Date', true),
                child: const Text('Select Savings Start Date'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, 'Savings End Date', false),
                child: const Text('Select Savings End Date'),
              ),
            ],
          ),
        ),
        if (savingsHistory.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.builder(
                itemCount: savingsHistory.length ~/ 2,
                itemBuilder: (context, index) {
                  final int startIndex = index * 2;
                  final String startDate = savingsHistory[startIndex];
                  final String endDate = savingsHistory[startIndex + 1];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Start Date: $startDate',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        subtitle: Text(
                          'End Date: $endDate',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              savingsHistory.removeAt(startIndex);
                              savingsHistory.removeAt(startIndex);
                              _saveSavingsHistory();
                            });
                          },
                        ),
                      ),
                      if (index != savingsHistory.length ~/ 2 - 1)
                        const Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectTransaction(
      BuildContext context, String title, bool isLoan) async {
    if (isLoan) {
      final TextEditingController _amountTakenController =
          TextEditingController();
      final TextEditingController _interestController = TextEditingController();
      final TextEditingController _amountReturnedController =
          TextEditingController();

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountTakenController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Amount Taken'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _interestController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Interest (%)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountReturnedController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Amount Returned'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_amountTakenController.text.isNotEmpty &&
                          _interestController.text.isNotEmpty &&
                          _amountReturnedController.text.isNotEmpty) {
                        final double amountTaken =
                            double.tryParse(_amountTakenController.text) ?? 0.0;
                        final double interest =
                            double.tryParse(_interestController.text) ?? 0.0;
                        final double amountReturned =
                            double.tryParse(_amountReturnedController.text) ??
                                0.0;
                        setState(() {
                          if (isLoan) {
                            loanHistory.add(
                                'Amount Taken: $amountTaken, Interest: $interest%, Amount Returned: $amountReturned');
                            _saveLoanHistory();
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      final TextEditingController _amountSavedController =
          TextEditingController();

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountSavedController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Amount Saved'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_amountSavedController.text.isNotEmpty) {
                        final double amountSaved =
                            double.tryParse(_amountSavedController.text) ?? 0.0;
                        setState(() {
                          if (!isLoan) {
                            savingsHistory.add('Amount Saved: $amountSaved');
                            _saveSavingsHistory();
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildTransactionHistoryTab(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    _selectTransaction(context, 'Add Loan Transaction', true),
                child: const Text('Add Loan Transaction'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _selectTransaction(
                    context, 'Add Savings Transaction', false),
                child: const Text('Add Savings Transaction'),
              ),
            ],
          ),
        ),
        if (transactionHistory.isNotEmpty)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.builder(
                itemCount: transactionHistory.length,
                itemBuilder: (context, index) {
                  final String transaction = transactionHistory[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Transaction: $transaction',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              transactionHistory.removeAt(index);
                              _saveTransactionHistory();
                            });
                          },
                        ),
                      ),
                      if (index != transactionHistory.length - 1)
                        const Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
