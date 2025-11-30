import 'package:bytebank_app/firebase_auth.dart';
import 'package:bytebank_app/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bytebank_app/pages/home.dart';
import 'package:bytebank_app/pages/investiments.dart';
import 'package:bytebank_app/pages/others_services.dart';
import 'package:bytebank_app/pages/bank_statement.dart';

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

  // Login function
  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      await Auth().signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      setState(() => _isLoggedIn = true);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
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
            'Faça login para continuar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Email',
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
              labelText: 'Senha',
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
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Register()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(195, 41, 202, 27),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Registre-se', style: TextStyle(fontSize: 16)),
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
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Investimentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Transferências',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
      body: switch (selectedIndex) {
        0 => Home(),
        1 => Investiments(),
        2 => BankStatement(),
        3 => OthersServices(),
        _ => Center(child: Text("Page not found")),
      },
    );
  }
}
