import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:KcfApp/resources/auth_methods.dart';
import 'package:KcfApp/responsive/mobile_screen_layout.dart';
import 'package:KcfApp/responsive/responsive_layout_scrteen.dart';
import 'package:KcfApp/responsive/web_screen_layout.dart';
import 'package:KcfApp/screens/forgot_password_screen.dart'; 
import 'package:KcfApp/screens/signup_screen.dart';
import 'package:KcfApp/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>  const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  void navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color logoColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    Color carouselTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    Color carouselBackgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black54
        : Colors.yellow[100]!;

    final List<Widget> cautionMessages = [
      Text(
        'Ensure you have an internet connection.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        'Navigate to the Sign Up screen if you are a new user.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        'Sign Up as a new user.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        'After Sign Up Login using your Email and Password.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        'Make sure you have access to your email.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      
      Text(
        'You can only choose one saving plan.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        'The monthly saving plan is the most recommended.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        'For any questions please find our contacts on the more page.',
        style: TextStyle(fontSize: 14, color: carouselTextColor),
        textAlign: TextAlign.center,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/L.png',
                  height: 120,
                  color: logoColor,
                ),
                const SizedBox(height: 24),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 60.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 2.0,
                    autoPlayInterval: const Duration(seconds: 5),
                  ),
                  items: cautionMessages.map((widget) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: carouselBackgroundColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: widget,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(
                      Icons.email,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 8), 
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: navigateToForgotPassword,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48, 
                  child: InkWell(
                    onTap: loginUser,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromARGB(255, 99, 174, 236),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : const Text('Log in'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text("Don't have an account?"),
                      ),
                    ),
                    const SizedBox(width: 6), 
                    GestureDetector(
                      onTap: navigateToSignup,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
