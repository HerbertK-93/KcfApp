import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class LoansPage extends StatefulWidget {
  LoansPage({
    super.key,
    required this.onLoanInfoConfirmed,
    required this.startDate,
    required this.loanAmount,
    required this.endDate,
    required this.interestRate,
  });

  final Function(double, DateTime, DateTime, double) onLoanInfoConfirmed;
  DateTime startDate;
  final double loanAmount;
  DateTime endDate;
  double interestRate;

  @override
  _LoansPageState createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  double amountToReturn = 0.0;
  double loanAmount = 0.0;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loanAmount = widget.loanAmount;
    calculateAmountToReturn();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: const Text('Loans'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Loan Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  loanAmount = double.tryParse(value) ?? 0.0;
                  calculateAmountToReturn();
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<double>(
              value: widget.interestRate,
              onChanged: (value) {
                setState(() {
                  widget.interestRate = value ?? 0.0;
                  calculateAmountToReturn();
                });
              },
              decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
              items: [10.0, 15.0, 20.0].map((rate) {
                return DropdownMenuItem<double>(
                  value: rate,
                  child: Text('$rate %'),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Amount to Return: $amountToReturn'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.onLoanInfoConfirmed(loanAmount, widget.startDate,
                      widget.endDate, widget.interestRate);
                  _showPaymentOptions();
                },
                child: const Text('Confirm Loan With Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          widget.startDate = pickedDate;
          _startDateController.text = pickedDate.toString().substring(0, 10);
        } else {
          widget.endDate = pickedDate;
          _endDateController.text = pickedDate.toString().substring(0, 10);
        }
      });
    }
  }

  void calculateAmountToReturn() {
    setState(() {
      amountToReturn = loanAmount * (1 + widget.interestRate / 100);
    });
  }

  void _showPaymentOptions() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.2, // Adjust the height as per your requirement
        child: Center(
          child: ListTile(
            title: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                const url = 'https://flutterwave.com/pay/g3vpxdi0d3n8';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Tap here to initiate payment',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    },
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );
}
}