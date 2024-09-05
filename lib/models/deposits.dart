import 'package:cloud_firestore/cloud_firestore.dart';

class Deposit {
  final String amount;
  final String currency;
  final String date;
  final String txRef;
  final String status;

  Deposit({
    required this.amount,
    required this.currency,
    required this.date,
    required this.txRef,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
      'date': date,
      'tx_ref': txRef,
      'status': status,
    };
  }

  factory Deposit.fromMap(Map<String, dynamic> map) {
    return Deposit(
      amount: map['amount'],
      currency: map['currency'],
      date: map['date'],
      txRef: map['tx_ref'],
      status: map['status'],
    );
  }
}
