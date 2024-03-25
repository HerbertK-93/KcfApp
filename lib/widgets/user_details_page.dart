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

  @override
  void initState() {
    super.initState();
    _loadLoanHistory();
    _loadSavingsHistory();
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

  Future<void> _selectDate(
      BuildContext context, String title, bool isStartDate, bool isLoan) async {
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
        if (isLoan) {
          if (isStartDate) {
            _startDate = pickedDate;
          } else {
            _endDate = pickedDate;
          }
          loanHistory.add(DateFormat('yyyy-MM-dd').format(pickedDate));
        } else {
          if (isStartDate) {
            _startDate = pickedDate;
          } else {
            _endDate = pickedDate;
          }
          savingsHistory.add(DateFormat('yyyy-MM-dd').format(pickedDate));
        }
      });
      if (isLoan) {
        await _saveLoanHistory();
      } else {
        await _saveSavingsHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
          bottom: const TabBar(
            isScrollable: true, // Make the TabBar scrollable
            tabs: [
              Tab(text: 'Loans History'),
              Tab(text: 'Savings History'),
              Tab(text: 'Transaction History'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context)
                .size
                .height, // Match the height of the screen
            child: TabBarView(
              children: [
                // Loan History Tab
                _buildLoanHistoryTab(context),
                // Savings History Tab
                _buildSavingsHistoryTab(context),
                // Transaction History Tab
                const Center(
                  child: Text('Transaction History Content'),
                ),
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
        const SizedBox(height: 16), // Add padding above the date pickers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () =>
                  _selectDate(context, 'Loan Start Date', true, true),
              child: const Text('Select Loan Start Date'),
            ),
            const SizedBox(width: 8), // Add spacing between buttons
            ElevatedButton(
              onPressed: () =>
                  _selectDate(context, 'Loan End Date', false, true),
              child: const Text('Select Loan End Date'),
            ),
          ],
        ),
        if (loanHistory.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0), // Add vertical padding
              child: ListView.builder(
                itemCount: loanHistory.length ~/ 2, // Display each loan session
                itemBuilder: (context, index) {
                  final int startIndex = index * 2;
                  final String startDate = loanHistory[startIndex];
                  final String endDate = loanHistory[startIndex + 1];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Start Date: $startDate',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1, // Apply the same font style
                        ),
                        subtitle: Text(
                          'End Date: $endDate',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1, // Apply the same font style
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              loanHistory
                                  .removeAt(startIndex); // Remove start date
                              loanHistory
                                  .removeAt(startIndex); // Remove end date
                              _saveLoanHistory(); // Save updated loan history
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
        const SizedBox(height: 16), // Add padding above the date pickers
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        _selectDate(context, 'Savings Start Date', true, false),
                    child: const Text('Select Savings Start Date'),
                  ),
                  const SizedBox(width: 8), // Add spacing between buttons
                  ElevatedButton(
                    onPressed: () =>
                        _selectDate(context, 'Savings End Date', false, false),
                    child: const Text('Select Savings End Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (savingsHistory.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0), // Add vertical padding
              child: ListView.builder(
                itemCount:
                    savingsHistory.length ~/ 2, // Display each savings session
                itemBuilder: (context, index) {
                  final int startIndex = index * 2;
                  final String startDate = savingsHistory[startIndex];
                  final String endDate = savingsHistory[startIndex + 1];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Start Date: $startDate',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1, // Apply the same font style
                        ),
                        subtitle: Text(
                          'End Date: $endDate',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1, // Apply the same font style
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              savingsHistory
                                  .removeAt(startIndex); // Remove start date
                              savingsHistory
                                  .removeAt(startIndex); // Remove end date
                              _saveSavingsHistory(); // Save updated savings history
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
}
