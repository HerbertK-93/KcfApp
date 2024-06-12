import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KcfApp/providers/deposit_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedCurrency = 'UGX';
  final List<String> _currencies = [
    'UGX', 'USD', 'EUR', 'GBP', 'KES', 'NGN', 'ZAR', 'AED', 'JOD', 'OMR', 'QAR', 'RWF', 'SAR', 'TZS', 'TRY', 'AED',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositProvider = Provider.of<DepositProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter Amount'),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter the amount',
                  suffix: SizedBox(
                    height: 24,
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      items: _currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                      underline: Container(),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Enter Date'),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Select date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    depositProvider.addDeposit(
                      _amountController.text,
                      _dateController.text,
                      _selectedCurrency,
                    );

                    const flutterwaveUrl = "https://flutterwave.com/pay/fnmb9lzxfbfu";
                    if (await canLaunchUrl(Uri.parse(flutterwaveUrl))) {
                      await launchUrl(Uri.parse(flutterwaveUrl));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch Flutterwave')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.purple,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Tap here to confirm and pay'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Deposits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...depositProvider.deposits.reversed.map((deposit) {
                int index = depositProvider.deposits.indexOf(deposit);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deposit ${index + 1}'),
                          const SizedBox(height: 4),
                          Text('Amount: ${deposit.amount} ${deposit.currency}'),
                          Text('Date: ${deposit.date}'),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          depositProvider.deleteDeposit(index);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
