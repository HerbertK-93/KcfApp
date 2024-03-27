// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kings_cogent/screens/agricultural_loan.dart';
import 'package:kings_cogent/screens/business_loan.dart';
import 'package:kings_cogent/screens/emergency_loan.dart';
import 'package:kings_cogent/screens/personal_loan.dart';
import 'package:kings_cogent/screens/profile_screen.dart';
import 'package:kings_cogent/screens/salary_loan_screen.dart';
import 'package:kings_cogent/screens/school_fees_loan_screen.dart';
import 'package:kings_cogent/widgets/sidebar.dart';
import 'package:shimmer/shimmer.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Text(
          'KINGS COGENT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'MadimiOne-Regular',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(
                    uid: '',
                  ),
                ),
              );
            },
            iconSize: 30,
          ),
        ],
      ),
      drawer: const SideBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.amberAccent,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Fast and Reliable Loans',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 170, // Adjust the height here
            child: CarouselSlider(
              carouselController: _carouselController,
              items: [
                // Carousel items here
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/caro 1.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/caro 2.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/caro 3.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/caro 4.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/caro 5.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
              options: CarouselOptions(
                height: 170, // Adjust the height here
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enableInfiniteScroll: true,
                pauseAutoPlayOnTouch: true,
                reverse: false,
                scrollDirection: Axis.horizontal,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {},
                scrollPhysics: const BouncingScrollPhysics(),
                padEnds: true,
              ),
            ),
          ),
          Container(
            color: const Color.fromARGB(137, 37, 37, 37),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 222, 151, 234),
                highlightColor: Colors.grey[100]!,
                period: const Duration(milliseconds: 1500),
                child: const Text(
                  'We Offer...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                children: [
                  LoanTile(
                    title: 'School Fees Loans',
                    imagePath: 'assets/images/school.png',
                    imageWidth: 140, // Adjusted width
                    imageHeight: 120, // Adjusted height
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SchoolFeesLoanScreen(),
                        ),
                      );
                    },
                  ),
                  LoanTile(
                    title: 'Salary Loans',
                    imagePath: 'assets/images/money.png',
                    imageWidth: 130, // Adjusted width
                    imageHeight: 120, // Adjusted height
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalaryLoanScreen(),
                        ),
                      );
                    },
                  ),
                  LoanTile(
                    title: 'Emergency Loans',
                    imagePath: 'assets/images/emergency.png',
                    imageWidth: 130, // Adjusted width
                    imageHeight: 120, // Adjusted height
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyLoanScreen(),
                        ),
                      );
                    },
                  ),
                  LoanTile(
                    title: 'Personal Loans',
                    imagePath: 'assets/images/personal loan.png',
                    imageWidth: 130, // Adjusted width
                    imageHeight: 120, // Adjusted height
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalLoanScreen(),
                        ),
                      );
                    },
                  ),
                  LoanTile(
                    title: 'Agricultural Loans',
                    imagePath: 'assets/images/tractor.png',
                    imageWidth: 130, // Adjusted width
                    imageHeight: 120, // Adjusted height
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgriculturalLoanScreen(),
                        ),
                      );
                    },
                  ),
                  LoanTile(
                    title: 'Business Loans',
                    imagePath: 'assets/images/business.png',
                    imageWidth: 120, // Adjusted width
                    imageHeight: 120, // Adjusted height
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusinessLoanScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Talk to us'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                        ),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Your Email',
                        ),
                      ),
                      TextField(
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Your Message',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'kingscogentfinance@gmail.com',
                        queryParameters: {
                          'subject': 'Subject',
                          'body': 'Your message here.'
                        },
                      );
                      final String urlString = emailLaunchUri.toString();
                      if (await canLaunch(urlString)) {
                        await launch(urlString);
                        // Show a SnackBar to confirm that the message has been sent
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Your message has been sent!'),
                            duration: Duration(seconds: 2), // Adjust as needed
                          ),
                        );
                        Navigator.of(context)
                            .pop(); // Close the dialog after sending
                      } else {
                        throw 'Could not launch $urlString';
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.purple.shade200,
        elevation: 20,
        child: const Icon(Icons.chat_bubble), // Change the color here
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPreviousButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        _carouselController.previousPage();
      },
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward_ios),
      onPressed: () {
        _carouselController.nextPage();
      },
    );
  }
}

class LoanTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final VoidCallback onTap;

  const LoanTile({
    super.key,
    required this.title,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey,
        child: SizedBox(
          height: 150, // Adjusted height
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  imagePath,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
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
