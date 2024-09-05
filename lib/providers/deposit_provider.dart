import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Deposit {
  final String amount;
  final String date;
  final String currency;

  Deposit({required this.amount, required this.date, required this.currency});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date,
      'currency': currency,
    };
  }

  factory Deposit.fromMap(Map<String, dynamic> map) {
    return Deposit(
      amount: map['amount'],
      date: map['date'],
      currency: map['currency'],
    );
  }
}

class DepositProvider with ChangeNotifier {
  List<Deposit> _deposits = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Deposit> get deposits => List.unmodifiable(_deposits);

  final Map<String, double> _conversionRates = {
    'UGX': 1,
    'USD': 3600,
    'EUR': 4200,
    'GBP': 5000,
    'KES': 35,
  };

  DepositProvider() {
    _loadDeposits();
  }

  void addDeposit(String amount, String date, String currency, {bool saveToFirestore = true}) async {
    if (!_isValidDouble(amount)) {
      throw FormatException('Invalid amount');
    }

    final newDeposit = Deposit(amount: amount, date: date, currency: currency);
    _deposits.add(newDeposit);
    _saveDeposits();
    notifyListeners();

    if (saveToFirestore) {
      await _saveDepositToFirestore(newDeposit);
    }
  }

  Future<void> _saveDepositToFirestore(Deposit deposit) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final txRef = DateTime.now().millisecondsSinceEpoch.toString();
      final depositData = {
        'amount': deposit.amount,
        'currency': deposit.currency,
        'tx_ref': txRef,
        'status': 'successful',
        'date': deposit.date,
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('deposits')
          .doc(txRef)
          .set(depositData);
    }
  }

  void deleteDeposit(int index) {
    if (index >= 0 && index < _deposits.length) {
      _deposits.removeAt(index);
      _saveDeposits();
      notifyListeners();
    }
  }

  double getTotalDepositsInUGX() {
    return _deposits.fold(0, (total, deposit) {
      if (_isValidDouble(deposit.amount)) {
        double amountInUGX = double.parse(deposit.amount) * _conversionRates[deposit.currency]!;
        return total + amountInUGX;
      } else {
        return total;
      }
    });
  }

  Future<void> _saveDeposits() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_deposits.map((d) => d.toMap()).toList());
    prefs.setString('deposits', encodedData);
  }

  Future<void> _loadDeposits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('deposits');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _deposits = decodedData.map((item) => Deposit.fromMap(item)).toList();
      notifyListeners();
    }
  }

  bool _isValidDouble(String value) {
    return double.tryParse(value) != null;
  }
}
