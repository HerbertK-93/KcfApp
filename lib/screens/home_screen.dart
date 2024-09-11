import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:KcfApp/providers/deposit_provider.dart';
import 'package:KcfApp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'alltransactions_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _visibleSection = "deposits"; // Default to showing deposits

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  double previousDepositsUGX = 0;
  double previousReturns = 0;
  double totalDepositsUGX = 0.0;
  double totalReturnsUGX = 0.0; // Adding totalReturnsUGX for Returns
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Update the tween to slide horizontally (left to right)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // Start from the left (off-screen)
      end: const Offset(0, 0),    // End at the center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward(); // Start with the first card visible

    // Fetch the initial data
    _calculateTotalDepositsUGX().then((value) {
      setState(() {
        totalDepositsUGX = value;
        isLoading = false;
      });
    });

    _calculateTotalReturnsUGX().then((value) {  // Fetch total returns UGX
      setState(() {
        totalReturnsUGX = value;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVisibility(String section) {
    setState(() {
      _visibleSection = section;  // Update the visible section
      _controller.reset();
      _controller.forward();  // Re-run the animation when the section changes
    });
  }

  // Fetch deposit transactions for the Deposits section
  Stream<QuerySnapshot> _getRecentDepositTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transactions')
        .where('transaction_type', isEqualTo: 'deposit')  // Fetch deposit transactions
        .snapshots();
  }

  // Fetch recent transactions for the Returns section
  Stream<QuerySnapshot> _getMonthlyTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transactions')
        .where('transaction_type', isEqualTo: 'monthly')  // Fetch only monthly transactions
        .snapshots();
  }

  // Function to calculate total successful deposits in UGX
  Future<double> _calculateTotalDepositsUGX() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transactions')
        .where('transaction_type', isEqualTo: 'deposit')
        .where('status', isEqualTo: 'successful')  // Only successful transactions
        .get();

    double totalDepositsUGX = 0.0;
    for (var doc in snapshot.docs) {
      totalDepositsUGX += double.parse(doc['amount'].toString());
    }

    return totalDepositsUGX;
  }

  // Function to calculate total successful returns in UGX (for the Returns section)
  Future<double> _calculateTotalReturnsUGX() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transactions')
        .where('transaction_type', isEqualTo: 'monthly')
        .where('status', isEqualTo: 'successful')  // Only successful transactions
        .get();

    double totalReturnsUGX = 0.0;
    for (var doc in snapshot.docs) {
      totalReturnsUGX += double.parse(doc['amount'].toString());
    }

    return totalReturnsUGX;
  }

  // Function to format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y, h:mm a').format(dateTime);
  }

  // Function to get status icon based on the transaction status
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

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final depositProvider = Provider.of<DepositProvider>(context);

    final String totalDepositsUSD = (totalDepositsUGX / 3600).toStringAsFixed(2);
    final String totalReturnsUSD = (totalReturnsUGX / 3600).toStringAsFixed(2);  // Convert returns to USD

    bool isDepositsIncreasing = totalDepositsUGX > previousDepositsUGX;
    bool isReturnsIncreasing = totalReturnsUGX > previousReturns;

    previousDepositsUGX = totalDepositsUGX;
    previousReturns = totalReturnsUGX;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildSectionToggle(),
              const SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimation,
                child: _visibleSection == 'deposits'
                    ? _buildCard(
                        context,
                        icon: Icons.account_balance_wallet,
                        title: 'Total Deposits',
                        amountUGX: totalDepositsUGX,
                        amountUSD: totalDepositsUSD,
                        gradientColors: [const Color(0xFF56ab2f), const Color(0xFFCDE345)],
                        isIncreasing: isDepositsIncreasing,
                      )
                    : _buildCard(
                        context,
                        icon: FontAwesomeIcons.chartLine,
                        title: 'Total Returns',
                        amountUGX: totalReturnsUGX,  // Updated for Returns UGX
                        amountUSD: totalReturnsUSD,  // Updated for Returns USD
                        gradientColors: [const Color(0xFF30C7DA), const Color(0xFF245BB2)],
                        isIncreasing: isReturnsIncreasing,
                      ),
              ),
              const SizedBox(height: 24),
              const FinancialTipsCarousel(),
              const SizedBox(height: 24),

              // Recent Transactions for Deposits
              if (_visibleSection == 'deposits') ...[
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16), // Add some spacing
                _buildDepositTransactionsSection(), // Show recent deposit transactions
              ],

              // Recent Transactions for Returns (Renamed Monthly to Recent Transactions)
              if (_visibleSection == 'returns') ...[
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16), // Add some spacing
                _buildMonthlyTransactionsSection(), // Show recent transactions
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2E2E2E)
                : const Color(0xFFF3F4F6),
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1C1C1C)
                : const Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton('Deposits', 'deposits'),
          const SizedBox(width: 8),
          _buildToggleButton('Returns', 'returns'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title, String section) {
    return ElevatedButton(
      onPressed: () => _toggleVisibility(section),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _visibleSection == section ? Colors.purple.shade400 : Colors.purple.shade200,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double amountUGX,
    required String amountUSD,
    required List<Color> gradientColors,
    required bool isIncreasing,
  }) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${amountUGX.toStringAsFixed(2)} UGX',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '\$$amountUSD USD',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Independent Recent Transactions for Deposits Section
  Widget _buildDepositTransactionsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRecentDepositTransactionsStream(), // Fetch deposit transactions
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No recent transactions.');
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

  // Independent Recent Transactions Section (renamed from Monthly)
  Widget _buildMonthlyTransactionsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getMonthlyTransactionsStream(), // Fetch monthly transactions
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No recent transactions.');
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
}

class FinancialTipsCarousel extends StatelessWidget {
  const FinancialTipsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 120,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
      items: [
        'Web version',
        'Loans with good interest rates',
        'Emergency fund',
        'Kings Cogent visa Card',
        'Kings Cogent mobile wallet',
        'Financial Benefits and Incentives',
        'Awards to our best customers',
        'And much more!',
      ].map((tip) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFE3E4E5),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
