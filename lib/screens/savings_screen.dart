import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, DateTime>> savingsHistory = [];

  CollectionReference savingsCollection =
      FirebaseFirestore.instance.collection('savings');

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    DocumentSnapshot documentSnapshot =
        await savingsCollection.doc('user_id').get();
    if (documentSnapshot.exists) {
      setState(() {
        _startDate = DateTime.parse(documentSnapshot['start_date']);
        _endDate = DateTime.parse(documentSnapshot['end_date']);
        List<dynamic> history = documentSnapshot['history'];
        savingsHistory = history
            .map<Map<String, DateTime>>((entry) => {
                  'start': DateTime.parse(entry['start']),
                  'end': DateTime.parse(entry['end'])
                })
            .toList();
      });
    }
  }

  Future<void> _saveDates() async {
    try {
      await savingsCollection.doc('user_id').set({
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'history': savingsHistory
            .map((entry) => {
                  'start': entry['start']!.toIso8601String(),
                  'end': entry['end']!.toIso8601String()
                })
            .toList(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dates saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save dates')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings History',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Start Date: ${_startDate?.toLocal() ?? 'Select start date'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'End Date: ${_endDate?.toLocal() ?? 'Select end date'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: savingsHistory.length,
              itemBuilder: (BuildContext context, int index) {
                final entry = savingsHistory[index];
                final start = entry['start'];
                final end = entry['end'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        'Start Date: ${DateFormat('yyyy-MM-dd').format(start!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'End Date: ${DateFormat('yyyy-MM-dd').format(end!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
        _addSavingsToHistory(); // Add selected date range to savings history
        _saveDates(); // Save dates to Firestore
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
        _addSavingsToHistory(); // Add selected date range to savings history
        _saveDates(); // Save dates to Firestore
      });
    }
  }

  void _addSavingsToHistory() {
    if (_startDate != null && _endDate != null) {
      print('Start Date: $_startDate, End Date: $_endDate'); // Debugging step
      final savingsEntry = {'start': _startDate!, 'end': _endDate!};
      print('Savings Entry: $savingsEntry'); // Debugging step
      setState(() {
        savingsHistory.add(savingsEntry);
      });
    }
  }
}
