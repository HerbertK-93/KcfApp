import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KcfApp/providers/transaction_provider.dart';
import 'package:KcfApp/models/flutterwave.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late DateTime _selectedDate = DateTime.now();

  double _localAmount = 20;
  double _localCalculatedAmount = 0.0;
  String _localRawAmount = '20';
  final TextEditingController _localAmountController = TextEditingController(text: '');
  final NumberFormat _localNumberFormat = NumberFormat.currency(locale: 'en_US', symbol: '');

  double _intlAmount = 20;
  double _intlCalculatedAmount = 0.0;
  String _intlRawAmount = '20';
  final TextEditingController _intlAmountController = TextEditingController(text: '');
  final NumberFormat _intlNumberFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);

  final double _interestRate = 0.12;
  final FlutterwaveService _flutterwaveService = FlutterwaveService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _periodController = TextEditingController(text: '6 months');
  bool _isProcessing = false;

  int _selectedInterface = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _calculateLocalSavings();
    _calculateIntlSavings();
    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _localAmountController.dispose();
    _intlAmountController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _periodController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(_selectedDate);
        _calculateLocalSavings();
        _calculateIntlSavings();
      });
    }
  }

  void _calculateLocalSavings() {
    setState(() {
      _localAmount = double.tryParse(_localRawAmount) ?? 0.0;
      _localCalculatedAmount = _localAmount + (_localAmount * _interestRate);
    });
  }

  void _calculateIntlSavings() {
    setState(() {
      _intlAmount = double.tryParse(_intlRawAmount) ?? 0.0;
      _intlCalculatedAmount = _intlAmount + (_intlAmount * _interestRate);
    });
  }

  double _calculateAnnualInterest(double amount) {
    return amount * 0.08;
  }

  void _formatAndSetLocalAmount(String value) {
    _localRawAmount = value.replaceAll(',', '');

    if (_localRawAmount.isNotEmpty) {
      double parsedValue = double.tryParse(_localRawAmount) ?? 0.0;
      String formattedAmount = _localNumberFormat.format(parsedValue);

      int cursorPosition = _localAmountController.selection.baseOffset;

      _localAmountController.value = TextEditingValue(
        text: formattedAmount,
        selection: TextSelection.collapsed(offset: cursorPosition + (formattedAmount.length - value.length)),
      );
    } else {
      _localAmountController.clear();
    }
    _calculateLocalSavings();
  }

  void _formatAndSetIntlAmount(String value) {
    _intlRawAmount = value.replaceAll(',', '');

    if (_intlRawAmount.isNotEmpty) {
      double parsedValue = double.tryParse(_intlRawAmount) ?? 0.0;
      String formattedAmount = _intlNumberFormat.format(parsedValue);

      int newCursorPosition = _intlAmountController.selection.baseOffset + (formattedAmount.length - value.length);

      _intlAmountController.value = TextEditingValue(
        text: formattedAmount,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );

      _intlAmount = parsedValue;
    } else {
      _intlAmountController.clear();
    }
    _calculateIntlSavings();
  }

  Future<void> _initiatePayment() async {
    if (_emailController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all required fields')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final String txRef = DateTime.now().millisecondsSinceEpoch.toString();
      final String redirectUrl = 'yourapp://redirect';

      String paymentType = _selectedInterface == 0 ? 'mobilemoney' : 'card';
      String paymentOptions = _selectedInterface == 0 ? 'mobilemoney' : 'card, mobilemoney, ussd';
      double amount = _selectedInterface == 0 ? _localAmount : _intlAmount;
      String currency = _selectedInterface == 0 ? 'UGX' : 'USD';

      final paymentResponse = await _flutterwaveService.initiatePayment(
        txRef: txRef,
        amount: amount.toString(),
        currency: currency,
        redirectUrl: redirectUrl,
        email: _emailController.text,
        phoneNumber: '1234567890',
        paymentType: paymentType,
        paymentOptions: paymentOptions,
        transactionType: 'Weekly',  // Specify that this is a monthly saving plan
      );

      final paymentLink = paymentResponse['data']['link'];

      if (await canLaunchUrl(Uri.parse(paymentLink))) {
        await launchUrl(Uri.parse(paymentLink));
        bool isSuccessful = await _flutterwaveService.checkTransactionStatus(txRef);
        if (isSuccessful) {
          _saveTransactionHistory({
            'date': _selectedDate.toString().split(' ')[0],
            'amount': amount,
            'tx_ref': txRef,
            'status': 'successful',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful and recorded')),
          );

          Navigator.pop(context);
        } else {
          // Handle unsuccessful payment if needed
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch payment link')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment initiation failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _saveTransactionHistory(Map<String, dynamic> transaction) {
    Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);
  }

  Stream<QuerySnapshot> _getWeeklySavingsStream(bool isLocal) {
    String currency = isLocal ? 'UGX' : 'USD';  // Local uses UGX, Intl uses USD
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transactions')
        .where('transaction_type', isEqualTo: 'Weekly')
        .where('currency', isEqualTo: currency)
        .snapshots();
  }

  // Function to format the date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y, h:mm a').format(dateTime);  // Format: Aug 20, 2023, 4:30 PM
  }

  // Function to get a status icon
  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'failed':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  // UI for Monthly Savings section (Local/International)
  Widget _buildWeeklySavingsList(bool isLocal) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getWeeklySavingsStream(isLocal),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Determine the system's theme and adapt the CircularProgressIndicator's color
          final brightness = Theme.of(context).brightness;
          final indicatorColor = brightness == Brightness.dark ? Colors.white : Colors.black;

          return Center(
            child: SizedBox(
              width: 20,  // Size similar to sign-up screen
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,  // Stroke width
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),  // Adaptive color
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No weekly savings found.');
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index].data() as Map<String, dynamic>;
            final amount = transaction['amount'];
            final currency = transaction['currency'];
            final status = transaction['status'];
            final date = DateTime.parse(transaction['date']);

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currency $amount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _getStatusIcon(status),  // Status icon
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateTime(date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: status == 'successful'
                                ? Colors.green
                                : (status == 'pending' ? Colors.orange : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Local Interface with savings list
  Widget _buildLocalInterface() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Weekly Savings (Local)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _localAmountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter amount in UGX',
              ),
              keyboardType: TextInputType.number,
              onChanged: _formatAndSetLocalAmount,
            ),
            const SizedBox(height: 16),
            Text(
              'Estimated Annual Interest: UGX ${_localNumberFormat.format(_calculateAnnualInterest(_localAmount))}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm'),
            ),
            const SizedBox(height: 20),
            _buildWeeklySavingsList(true),  // Local savings list
          ],
        ),
      ),
    );
  }

  // International Interface with savings list
  Widget _buildInternationalInterface() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Weekly Savings (International)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _intlAmountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter amount in USD',
              ),
              keyboardType: TextInputType.number,
              onChanged: _formatAndSetIntlAmount,
            ),
            const SizedBox(height: 16),
            Text(
              'Estimated Annual Interest: USD ${_intlNumberFormat.format(_calculateAnnualInterest(_intlAmount))}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm'),
            ),
            const SizedBox(height: 20),
            _buildWeeklySavingsList(false),  // International savings list
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonInterface() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'USSD Payment',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Coming Soon...',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Weekly Plan'),
    ),
    body: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildInterfaceCard(
                index: 0,
                icon: Icons.home,
                label: 'Local',
                isSelected: _selectedInterface == 0,
                onTap: () {
                  setState(() {
                    _selectedInterface = 0;
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildInterfaceCard(
                index: 1,
                icon: Icons.public,
                label: 'International',
                isSelected: _selectedInterface == 1,
                onTap: () {
                  setState(() {
                    _selectedInterface = 1;
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildInterfaceCard(
                index: 2,
                icon: Icons.phone_android,
                label: 'USSD',
                isSelected: _selectedInterface == 2,
                onTap: () {
                  setState(() {
                    _selectedInterface = 2;
                    _pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              _buildScrollableInterface(_buildLocalInterface()),  // Local Savings UI
              _buildScrollableInterface(_buildInternationalInterface()),  // International Savings UI
              _buildScrollableInterface(_buildComingSoonInterface()),  // USSD UI
            ],
            onPageChanged: (index) {
              setState(() {
                _selectedInterface = index;
              });
            },
          ),
        ),
      ],
    ),
  );
}

// Helper function to wrap each interface in a scrollable view
Widget _buildScrollableInterface(Widget child) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),  // Add some padding for better UX
      child: child,
    ),
  );
}


  Widget _buildInterfaceCard({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: isSelected ? (isDarkTheme ? Colors.purple : theme.primaryColor) : theme.cardColor,
        child: SizedBox(
          width: 120, // Uniform width
          height: 110, // Uniform height
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: isSelected ? Colors.white : theme.iconTheme.color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.textTheme.bodyText1?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
