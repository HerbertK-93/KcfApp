import 'package:KcfApp/providers/savings_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ReturnsScreen extends StatelessWidget {
  final double totalSavingsUGX;

  const ReturnsScreen({Key? key, required this.totalSavingsUGX}) : super(key: key);

  // Function to calculate returns with 8% annual interest
  double calculateReturns(double principal, double rate, int years) {
    return principal * (1 + rate * years);
  }

  @override
  Widget build(BuildContext context) {
    // Access the updated total savings from the provider
    double totalSavingsUGX = Provider.of<SavingsProvider>(context).totalSavings;

    // Calculate the returns for 1 year at 8% interest rate
    double annualInterestRate = 0.08;
    int years = 1; // Assuming we're calculating for 1 year
    double totalReturns = calculateReturns(totalSavingsUGX, annualInterestRate, years);

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Returns', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.assignment_return,
                size: 80,
                color: Colors.purple,
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Savings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 30,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${totalSavingsUGX.toStringAsFixed(2)} UGX',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Returns',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.coins,
                            size: 30,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${totalReturns.toStringAsFixed(2)} UGX',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
