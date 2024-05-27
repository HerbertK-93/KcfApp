import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kings_cogent/screens/login_screen.dart';
import 'package:kings_cogent/responsive/mobile_screen_layout.dart';
import 'package:kings_cogent/responsive/responsive_layout_scrteen.dart';
import 'package:kings_cogent/responsive/web_screen_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2), () {});

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return  ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: brightness == Brightness.dark ? const Color.fromARGB(255, 36, 35, 35) : Colors.white,
      body: Center(
        child: Container(
          color: brightness == Brightness.dark ? const Color.fromARGB(255, 36, 35, 35) : Colors.white, 
          child: ImageFiltered(
            imageFilter: ColorFilter.mode(
              brightness == Brightness.dark ? Colors.white :  const Color.fromARGB(255, 36, 35, 35), 
              BlendMode.srcATop,
            ),
            child: Image.asset(
              'assets/images/S-S.png', 
              height: 90,
            ),
          ),
        ),
      ),
    );
  }
}

