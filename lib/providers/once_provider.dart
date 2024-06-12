import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnceProvider with ChangeNotifier {
  List<Map<String, dynamic>> _transactionHistory = [];
  List<Map<String, dynamic>> get transactionHistory => _transactionHistory;

  OnceProvider() {
    _loadTransactionHistory();
  }

  void _loadTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('once_transaction_history');
    if (history != null) {
      _transactionHistory = history.map((item) {
        Map<String, dynamic> transaction = {};
        List<String> details = item.split('|');
        transaction['day'] = details[0];
        transaction['amount'] = double.parse(details[1]);
        return transaction;
      }).toList();
      notifyListeners();
    }
  }

  void addTransaction(String day, double amount) async {
    _transactionHistory.insert(0, {'day': day, 'amount': amount});
    _saveTransactionHistory();
    notifyListeners();
  }

  void _saveTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = _transactionHistory.map((transaction) {
      return '${transaction['day']}|${transaction['amount']}';
    }).toList();
    await prefs.setStringList('once_transaction_history', history);
  }

  Future<void> saveTransactionToFirestore(
    DateTime selectedDate,
    double onceDeposit,
    double interestRate,
    String period,
    double amount,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('once_plan').add({
        'selected_day': selectedDate,
        'oncedeposit': onceDeposit,
        'interest_rate': interestRate,
        'period': period,
        'amount': amount,
      });
    } catch (error) {
      print('Error saving transaction: $error');
    }
  }

  void deleteTransaction(int index) {
    _transactionHistory.removeAt(index);
    _saveTransactionHistory();
    notifyListeners();
  }
}