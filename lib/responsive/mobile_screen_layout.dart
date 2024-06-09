import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kings_cogent/screens/alltransactions_screen.dart';
import 'package:kings_cogent/screens/profile_screen.dart';
import 'package:kings_cogent/screens/navigation_instructions_screen.dart';
import 'package:kings_cogent/screens/save_screen.dart';
import 'package:kings_cogent/widgets/sidebar.dart';
import 'package:kings_cogent/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  _MobileScreenLayoutState createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> with SingleTickerProviderStateMixin {
  bool _isFiguresVisible = false;
  bool _isNavigationTagVisible = true;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

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

    _loadNavigationTagVisibility();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNavigationTagVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final isVisible = prefs.getBool('isNavigationTagVisible') ?? true;
    setState(() {
      _isNavigationTagVisible = isVisible;
    });
    if (!isVisible) {
      _controller.value = 1.0; // Set the animation to the end state
    }
  }

  Future<void> _hideNavigationTag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNavigationTagVisible', false);
    _controller.forward().then((_) {
      setState(() {
        _isNavigationTagVisible = false;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    const conversionRate = 3600;
    final totalReturnsUGX = (transactionProvider.totalMonthlyReturns * conversionRate).toStringAsFixed(2);
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    final iconColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            onPressed: () async {
              const whatsappUrl = "https://wa.me/+256784480128"; // Replace with your WhatsApp number
              if (await canLaunch(whatsappUrl)) {
                await launch(whatsappUrl);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch WhatsApp')),
                );
              }
            },
            iconSize: 30,
          ),
        ],
      ),
      drawer: const SideBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          // Home Screen
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _isNavigationTagVisible
                        ? Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.blue,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const NavigationInstructionsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'How to navigate the App',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () async {
                                    await _hideNavigationTag();
                                  },
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                    child: Text(
                      'Balance',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(247, 160, 86, 49),
                      borderRadius: BorderRadius.circular(1), // Reduced roundness
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 27, 25, 25).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isFiguresVisible
                                        ? '\$${transactionProvider.totalMonthlyReturns.toStringAsFixed(2)} USD'
                                        : '******',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isFiguresVisible
                                        ? '($totalReturnsUGX UGX)'
                                        : '******',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFiguresVisible ? Icons.visibility : Icons.visibility_off,
                                color: iconColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFiguresVisible = !_isFiguresVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 80, 80, 80) : Color.fromARGB(255, 192, 191, 191),
                      borderRadius: BorderRadius.circular(1), // Reduced roundness
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        const flutterwaveUrl = "https://flutterwave.com/pay/fnmb9lzxfbfu"; // Replace with your Flutterwave link
                        if (await canLaunch(flutterwaveUrl)) {
                          await launch(flutterwaveUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch Flutterwave')),
                          );
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.wallet),
                      label: const Text('Deposit'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.purple : Colors.purple,
                        minimumSize: const Size.fromHeight(50), // Stretch button
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 4),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const FinancialTipsCarousel(),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transactions:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllTransactionsScreen(transactionHistory: transactionProvider.transactionHistory),
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
                  transactionProvider.transactionHistory.isEmpty
                      ? const Center(child: Text('No transactions yet'))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: transactionProvider.transactionHistory.length,
                          itemBuilder: (context, index) {
                            final transaction = transactionProvider.transactionHistory[index];
                            final date = transaction['date'];
                            final amount = transaction['amount'];
                            final monthlyReturns = amount + (amount * 0.12);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text('Transaction ${transactionProvider.transactionHistory.length - index}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: $date'),
                                    Text('Amount: \$$amount (${(amount * conversionRate).toStringAsFixed(2)} UGX)'),
                                    Text('Monthly Returns: \$${monthlyReturns.toStringAsFixed(2)} (${(monthlyReturns * conversionRate).toStringAsFixed(2)} UGX)'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          // Save Screen
          const SaveScreen(),
          // Profile Screen
          const ProfileScreen(uid: ''),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 8,
            ),
          ],
        ),
        child: AnimatedBottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Theme.of(context).textTheme.bodyLarge!.color),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance, color: Theme.of(context).textTheme.bodyLarge!.color),
              label: 'Save',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Theme.of(context).textTheme.bodyLarge!.color),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class AnimatedBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    Key? key, required Color selectedItemColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      selectedItemColor: Colors.purple, // Set to desired color (purple)
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 18,
      unselectedFontSize: 14,
      backgroundColor: Theme.of(context).bottomAppBarColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 10,
      unselectedItemColor: Colors.purple.withOpacity(0.3), // Set unselected with a lighter shade of purple
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
            borderRadius: BorderRadius.circular(5.0), // Reduced roundness
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
              style: TextStyle(fontSize: 18.0, color: textColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
