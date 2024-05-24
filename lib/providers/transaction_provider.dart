import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TransactionProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _transactionHistory = [];
  double _totalMonthlyReturns = 0.0;
  final double _interestRate = 0.12;
  SharedPreferences? _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionProvider() {
    _loadFromPrefs();
  }

  List<Map<String, dynamic>> get transactionHistory => _transactionHistory;
  double get totalMonthlyReturns => _totalMonthlyReturns;

  void addTransaction(Map<String, dynamic> transaction) async {
    _transactionHistory.insert(0, transaction);
    _totalMonthlyReturns += transaction['amount'] + (transaction['amount'] * _interestRate);
    _saveToPrefs();
    notifyListeners();

    // Save to Firestore
    try {
      await _firestore.collection('transactions').add(transaction);
    } catch (e) {
      print('Failed to save transaction to Firestore: $e');
    }
  }

  void _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? history = _prefs?.getStringList('transaction_history');
    if (history != null) {
      _transactionHistory = history.map((item) {
        Map<String, dynamic> transaction = json.decode(item);
        return transaction;
      }).toList();

      _totalMonthlyReturns = _transactionHistory.fold(0, (total, transaction) {
        return total + transaction['amount'] + (transaction['amount'] * _interestRate);
      });
      notifyListeners();
    }
  }

  void _saveToPrefs() async {
    List<String> history = _transactionHistory.map((transaction) {
      return json.encode(transaction);
    }).toList();
    await _prefs?.setStringList('transaction_history', history);
  }
}
