import 'package:bytebank_app/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bytebank_app/pages/home.dart';
import 'package:bytebank_app/pages/investiments.dart';
import 'package:bytebank_app/pages/others_services.dart';
import 'package:bytebank_app/pages/transfers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  bool _isLoggedIn = false;
  var selectedIndex = 0;

  // Controllers for login form
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fake credentials for demonstration
  final String _validUsername = 'user';
  final String _validPassword = '1234';

  // Login function
  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final isValidCredentials =
          username == _validUsername && password == _validPassword;

      if (!isValidCredentials) {
        _showSnackBar(context, 'Invalid username or password');
        return;
      }

      await Auth().createUserWithEmailAndPassword(
        email: username,
        password: password,
      );

      setState(() => _isLoggedIn = true);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = 'Something went wrong. Please try again.';
      }

      _showSnackBar(context, message);
      setState(() => _isLoggedIn = false);
    }
  }

  // Create Account function
  Future<void> _createUserWithEmailAndPassword() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      if (username == _validUsername && password == _validPassword) {
        await Auth().createUserWithEmailAndPassword(
          email: username,
          password: password,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    try {
      await Auth().signOut(); // ou FirebaseAuth.instance.signOut();
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _usernameController.clear();
        _passwordController.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error logging out')));
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !_isLoggedIn
          ? AppBar(title: Image.asset('assets/images/logo.png', height: 24))
          : null,
      body: _isLoggedIn ? _buildHomeView() : Center(child: _buildLoginForm()),
    );
  }

  /// Login form widget
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Login to continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(195, 41, 202, 27)),
              ),
              floatingLabelStyle: TextStyle(
                color: Color.fromARGB(195, 41, 202, 27),
                fontWeight: FontWeight.w600,
              ),
            ),
            cursorColor: Color.fromARGB(195, 41, 202, 27),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(195, 41, 202, 27)),
              ),
              floatingLabelStyle: TextStyle(
                color: Color.fromARGB(195, 41, 202, 27),
              ),
            ),
            obscureText: true,
            cursorColor: Color.fromARGB(195, 41, 202, 27),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _login,
            icon: const Icon(Icons.login),
            label: Text('Login'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Color.fromARGB(195, 41, 202, 27),
              foregroundColor: Colors.white,
              iconColor: Color.fromARGB(255, 255, 255, 255),
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Logged-in view widget
  Widget _buildHomeView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Image.asset('assets/images/logo.png', height: 24),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            color: const Color.fromARGB(195, 41, 202, 27),
            alignment: Alignment.center,
            onPressed: _logout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (newIndex) {
          setState(() {
            selectedIndex = newIndex;
          });
        },
        backgroundColor: const Color.fromARGB(255, 3, 3, 3),
        selectedItemColor: const Color.fromARGB(195, 41, 202, 27),
        unselectedItemColor: Colors.brown.shade50,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Investiments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Transfers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: switch (selectedIndex) {
        0 => Home(),
        1 => Investiments(),
        2 => Transfers(),
        3 => OthersServices(),
        _ => Center(child: Text("Page not found")),
      },
    );
  }
}
