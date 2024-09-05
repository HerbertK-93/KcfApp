import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:KcfApp/providers/deposit_provider.dart';
import 'package:KcfApp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'alltransactions_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide up from bottom
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start with the first card visible
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVisibility(String section) {
    setState(() {
      _visibleSection = section;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final depositProvider = Provider.of<DepositProvider>(context);

    double totalReturns = transactionProvider.totalMonthlyReturns;
    double totalDepositsUGX = depositProvider.getTotalDepositsInUGX();

    final double totalReturnsUGX = totalReturns * 3600;
    final String totalDepositsUSD = (totalDepositsUGX / 3600).toStringAsFixed(2);
    final String totalReturnsUSD = totalReturns.toStringAsFixed(2);

    bool isDepositsIncreasing = totalDepositsUGX > previousDepositsUGX;
    bool isReturnsIncreasing = totalReturns > previousReturns;

    previousDepositsUGX = totalDepositsUGX;
    previousReturns = totalReturns;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Container(
              // Adaptive background color based on the theme
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]  // Dark mode background color
                    : Colors.grey[350], // Light mode background color (Soft light grey)
                borderRadius: BorderRadius.circular(15), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildButton(
                          context,
                          title: 'Deposits',
                          section: 'deposits',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildButton(
                          context,
                          title: 'Returns',
                          section: 'returns',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Slide-in Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: _visibleSection == 'deposits'
                        ? _buildCard(
                            context,
                            icon: Icons.account_balance_wallet,
                            title: 'Total Deposits',
                            amountUGX: totalDepositsUGX,
                            amountUSD: totalDepositsUSD,
                            gradientColors: [
                              const Color(0xFF56ab2f),
                              Color.fromARGB(255, 246, 238, 148),
                            ],
                            isIncreasing: isDepositsIncreasing,
                          )
                        : _buildCard(
                            context,
                            icon: FontAwesomeIcons.chartLine,
                            title: 'Total Returns',
                            amountUGX: totalReturnsUGX,
                            amountUSD: totalReturnsUSD,
                            gradientColors: [
                              Color.fromARGB(255, 121, 240, 198),
                              const Color(0xFF2F80ED),
                            ],
                            isIncreasing: isReturnsIncreasing,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 4),
              child: Text(
                'Coming Soon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const FinancialTipsCarousel(),
            const SizedBox(height: 15),
            _buildTransactionsSection(context, transactionProvider, depositProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String title, required String section}) {
    return ElevatedButton(
      onPressed: () => _toggleVisibility(section),
      child: Text(title),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        minimumSize: const Size.fromHeight(50),
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
      height: 150, // Uniform height
      width: double.infinity, // Stretch to full width
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                '${amountUGX.toStringAsFixed(2)} UGX',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$$amountUSD USD',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(
    BuildContext context,
    TransactionProvider transactionProvider,
    DepositProvider depositProvider,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                final combinedHistory = [
                  ...transactionProvider.transactionHistory.map((transaction) {
                    return {
                      'date': transaction['date'],
                      'amount': transaction['amount'],
                      'type': 'transaction',
                    };
                  }),
                  ...depositProvider.deposits.map((deposit) {
                    return {
                      'date': deposit.date,
                      'amount': double.parse(deposit.amount),
                      'type': 'deposit',
                    };
                  }),
                ];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllTransactionsScreen(combinedHistory: combinedHistory),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 180, 43, 204)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactionProvider.transactionHistory.isEmpty &&
            depositProvider.deposits.isEmpty)
          const Center(child: Text('No transactions yet'))
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactionProvider.transactionHistory.length +
                depositProvider.deposits.length,
            itemBuilder: (context, index) {
              if (index < transactionProvider.transactionHistory.length) {
                final transaction = transactionProvider.transactionHistory[index];
                final date = transaction['date'];
                final amount = transaction['amount'];

                if (amount is! double || !amount.isFinite) {
                  return const Center(child: Text('Invalid transaction data'));
                }

                final monthlyReturns = amount + (amount * 0.12);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      'Transaction ${transactionProvider.transactionHistory.length - index}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: $date'),
                        Text('Amount: \$$amount (${(amount * 3600).toStringAsFixed(2)} UGX)'),
                        Text(
                          'Monthly Returns: \$${monthlyReturns.toStringAsFixed(2)} (${(monthlyReturns * 3600).toStringAsFixed(2)} UGX)',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        transactionProvider.deleteTransaction(index);
                      },
                    ),
                  ),
                );
              } else {
                final depositIndex = index - transactionProvider.transactionHistory.length;
                final deposit = depositProvider.deposits[depositIndex];
                final amount = double.tryParse(deposit.amount) ?? 0.0;

                if (!amount.isFinite) {
                  return const Center(child: Text('Invalid deposit data'));
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text('Deposit ${depositProvider.deposits.length - depositIndex}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${deposit.date}'),
                        Text('Amount: ${deposit.amount} ${deposit.currency}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        depositProvider.deleteDeposit(depositIndex);
                      },
                    ),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}

class FinancialTipsCarousel extends StatelessWidget {
  const FinancialTipsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.grey[850] : Colors.grey[350];
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    return CarouselSlider(
      options: CarouselOptions(height: 100, autoPlay: true, enlargeCenterPage: true),
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
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 18.0,
                color: textColor,
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
