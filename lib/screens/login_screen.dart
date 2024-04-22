import 'package:flutter/material.dart';
import 'package:kings_cogent/resources/auth_methods.dart';
import 'package:kings_cogent/responsive/mobile_screen_layout.dart';
import 'package:kings_cogent/responsive/responsive_layout_scrteen.dart';
import 'package:kings_cogent/responsive/web_screen_layout.dart';
import 'package:kings_cogent/screens/signup_screen.dart';
import 'package:kings_cogent/utils/utils.dart';
import 'package:kings_cogent/widgets/text_field_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

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
          builder: (context) => const ResponsiveLayout(
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

  @override
  Widget build(BuildContext context) {
    Color logoColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Image
              Image.asset(
                'assets/images/L.png',
                height: 120,
                color: logoColor,
              ),
              const SizedBox(height: 24),
              // Email TextField
              TextFieldInput(
                hintText: 'Enter your email',
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(height: 24),
              // Password TextField
              TextFieldInput(
                hintText: 'Enter your password',
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                isPass: true,
              ),
              const SizedBox(height: 24),
              // Login Button
              InkWell(
                onTap: loginUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.amberAccent,
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
              const SizedBox(height: 12),
              // Transition to signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle sign up text tap
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text("Don't have an account?"),
                    ),
                  ),
                  GestureDetector(
                    onTap: navigateToSignup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "Sign up",
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
    );
  }
}
