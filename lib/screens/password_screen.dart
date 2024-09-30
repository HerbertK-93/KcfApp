import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isFirstLaunch = false;
  bool _isConfirmingPassword = false; // To track password confirmation
  late AnimationController _controller;
  late Animation<double> _animation;
  List<String> _input = ["", "", "", ""];
  int _attemptsLeft = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    String? storedPassword = await _storage.read(key: 'user_password');
    if (storedPassword == null) {
      setState(() {
        _isFirstLaunch = true;
      });
    }
  }

  Future<void> _setPassword() async {
    final password = _input.join();
    if (_isConfirmingPassword) {
      final confirmPassword = _confirmPasswordController.text;
      if (password == confirmPassword) {
        await _storage.write(key: 'user_password', value: password);
        _navigateToHomeScreen();
      } else {
        _showError('Passwords do not match');
      }
    } else {
      setState(() {
        _isConfirmingPassword = true;
        _confirmPasswordController.text = password;
        _input = ["", "", "", ""];
      });
    }
  }

  Future<void> _validatePassword() async {
    final password = _input.join();
    String? storedPassword = await _storage.read(key: 'user_password');
    if (storedPassword == password) {
      _navigateToHomeScreen();
    } else {
      setState(() {
        _attemptsLeft--;
      });
      if (_attemptsLeft > 0) {
        _showError('Incorrect password. $_attemptsLeft attempts left.');
      } else {
        _handleLockout();
      }
    }
  }

  void _handleLockout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Attempts'),
        content: const Text(
            'You have entered the incorrect PIN too many times. Please try again later or reset your PIN.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onKeyTapped(String value) {
    setState(() {
      for (int i = 0; i < _input.length; i++) {
        if (_input[i].isEmpty) {
          _input[i] = value;
          break;
        }
      }
      if (_input.every((element) => element.isNotEmpty)) {
        _isFirstLaunch ? _setPassword() : _validatePassword();
      }
    });
  }

  void _onBackspaceTapped() {
    setState(() {
      for (int i = _input.length - 1; i >= 0; i--) {
        if (_input[i].isNotEmpty) {
          _input[i] = "";
          break;
        }
      }
    });
  }

  void _handleForgotPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN'),
        content: const Text(
            'To reset your PIN, please contact support at:\n\n'
            'Phone: +256 701936975\n'
            'Email: kingscogentfinance@gmail.com'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(int index) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Text(
        _input[index],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        if (index < 9) {
          return ElevatedButton(
            onPressed: () => _onKeyTapped((index + 1).toString()),
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else if (index == 9) {
          return const SizedBox.shrink();
        } else if (index == 10) {
          return ElevatedButton(
            onPressed: () => _onKeyTapped("0"),
            child: const Text(
              "0",
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else {
          return ElevatedButton(
            onPressed: _onBackspaceTapped,
            child: const Icon(Icons.backspace_outlined, size: 16),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(), // Remove the title from the app bar
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView( // **Scrollable added here**
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // **Company Logo** (Ensure it's adaptive)
                Image.asset(
                  'assets/images/L.png',  // Your logo file
                  height: 150,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black, // Adapt to system theme
                ),
                const SizedBox(height: 20),
                Text(
                  _isFirstLaunch
                      ? (_isConfirmingPassword ? 'Confirm PIN' : 'Set PIN')
                      : 'Enter PIN',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, _buildInputField),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handleForgotPin,
                    child: const Text(
                      'Forgot PIN?',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildKeyboard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
