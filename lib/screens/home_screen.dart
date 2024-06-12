import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:KcfApp/providers/deposit_provider.dart';
import 'package:KcfApp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'deposit_screen.dart';
import 'alltransactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isFiguresVisible = true;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

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
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final depositProvider = Provider.of<DepositProvider>(context);

    double totalReturns = transactionProvider.totalMonthlyReturns;
    double totalDepositsUGX = depositProvider.getTotalDepositsInUGX();

    final totalReturnsUGX = (totalReturns * 3600).toStringAsFixed(2);

    final textColor = Theme.of(context).textTheme.bodyLarge!.color;

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
            _buildCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Total Deposits',
              amount: totalDepositsUGX,
              currency: 'UGX',
              gradientColors: [
                const Color.fromARGB(255, 133, 127, 66)!,
                const Color.fromARGB(255, 88, 151, 151)!
              ],
              isIncreasing: isDepositsIncreasing,
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: FontAwesomeIcons.chartLine,
              title: 'Total Returns',
              amount: totalReturns,
              currency: 'USD',
              subtitle: '($totalReturnsUGX UGX)',
              gradientColors: [const Color.fromARGB(255, 77, 199, 255), const Color.fromARGB(255, 107, 209, 172)],
              isIncreasing: isReturnsIncreasing,
            ),
            const SizedBox(height: 16),
            _buildDepositButton(context),
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

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double amount,
    required String currency,
    String? subtitle,
    required List<Color> gradientColors,
    required bool isIncreasing,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        amount.toStringAsFixed(2),
                        key: ValueKey<double>(amount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      ' $currency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: isIncreasing ? const Color.fromARGB(255, 2, 111, 5) : Colors.grey,
                ),
                Icon(
                  Icons.arrow_downward,
                  color: isIncreasing ? Colors.grey : const Color.fromARGB(255, 219, 40, 27),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 80, 80, 80)
            : const Color.fromARGB(255, 192, 191, 191),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 27, 25, 25).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DepositScreen()),
          );
        },
        icon: const Icon(FontAwesomeIcons.wallet),
        label: const Text('Deposit'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
          minimumSize: const Size.fromHeight(50),
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
    final backgroundColor = isDarkTheme ? Colors.grey[800] : Colors.white;
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
