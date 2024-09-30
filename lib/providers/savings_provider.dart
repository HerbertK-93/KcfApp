import 'package:flutter/material.dart';

class SavingsProvider with ChangeNotifier {
  double _totalSavings = 0.0;

  double get totalSavings => _totalSavings;

  // Method to update total savings
  void updateSavings(double newSavings) {
    _totalSavings = newSavings;
    notifyListeners();  // Notify listeners of the change
  }

  // Method to add to total savings (like a transaction)
  void addSavings(double amount) {
    _totalSavings += amount;
    notifyListeners();
  }

  // Method to reset savings (if needed)
  void resetSavings() {
    _totalSavings = 0.0;
    notifyListeners();
  }
}
