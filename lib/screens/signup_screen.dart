import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kings_cogent/resources/auth_methods.dart';
import 'package:kings_cogent/screens/login_screen.dart';
import 'package:kings_cogent/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _ninPassportController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _whatsappController.dispose();
    _ninPassportController.dispose();
    super.dispose();
  }

  Future<void> selectImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
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
    if (_usernameController.text.isEmpty) {
      _showError('Please enter your username.');
      return;
    }
    if (_bioController.text.isEmpty) {
      _showError('Please enter your bio.');
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
    if (_image == null) {
      _showError('Please select a profile photo.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      whatsapp: _whatsappController.text,
      ninPassport: _ninPassportController.text,
      file: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (res.toLowerCase() != 'success') {
      showSnackBar(res, context);
    } else {
      await saveUserData(
        _emailController.text,
        _usernameController.text,
        _bioController.text,
        _whatsappController.text,
        _ninPassportController.text,
      );
      navigateToLogin();
    }
  }

  Future<void> saveUserData(String email, String username, String bio, String whatsapp, String ninPassport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('bio', bio);
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
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                              'https://th.bing.com/th?id=OIP.SAcV4rjQCseubnk32USHigHaHx&w=244&h=256&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
                            )),
                    Positioned(
                      bottom: -10,
                      right: -3,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your username',
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Password must have more than six characters',
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                    SizedBox(width: 3),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your bio',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
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
