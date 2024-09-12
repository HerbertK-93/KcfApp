import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:KcfApp/resources/auth_methods.dart';
import 'package:KcfApp/screens/login_screen.dart';
import 'package:KcfApp/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _ninPassportController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _whatsappController.dispose();
    _ninPassportController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> signUpUser() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email.');
      return;
    }
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showError('Please enter a password with at least 6 characters.');
      return;
    }
    if (!_passwordController.text.contains(RegExp(r'[A-Z]')) || !_passwordController.text.contains(RegExp(r'[a-z]')) || !_passwordController.text.contains(RegExp(r'[0-9]'))) {
      _showError('Password must contain both uppercase, lowercase letters, and numbers.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match.');
      return;
    }
    if (_firstNameController.text.isEmpty) {
      _showError('Please enter your first name.');
      return;
    }
    if (_lastNameController.text.isEmpty) {
      _showError('Please enter your last name.');
      return;
    }
    if (_whatsappController.text.isEmpty) {
      _showError('Please enter your WhatsApp number.');
      return;
    }
    if (_ninPassportController.text.isEmpty) {
      _showError('Please enter your NIN or Passport number.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      whatsapp: _whatsappController.text,
      ninPassport: _ninPassportController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res.toLowerCase() != 'success') {
      showSnackBar(res, context);
    } else {
      await saveUserData(
        _emailController.text,
        _firstNameController.text,
        _lastNameController.text,
        _whatsappController.text,
        _ninPassportController.text,
      );
      navigateToLogin();
    }
  }

  Future<void> saveUserData(String email, String firstName, String lastName, String whatsapp, String ninPassport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('whatsapp', whatsapp);
    await prefs.setString('ninPassport', ninPassport);
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color logoColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

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
                const Text(
                  'Please enter all fields to be able to Sign Up',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 4),
                const SizedBox(height: 12),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your first name',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your last name',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
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
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password must have more than six characters and contain numbers, uppercase and lowercase letters.',
                    style: TextStyle(color: Colors.red, fontSize: 10),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your WhatsApp number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _ninPassportController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your NIN or Passport number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
