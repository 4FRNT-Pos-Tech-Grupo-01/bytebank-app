import 'package:flutter/material.dart';

import 'package:bytebank_app/pages/home.dart';
import 'package:bytebank_app/pages/investiments.dart';
import 'package:bytebank_app/pages/others_services.dart';
import 'package:bytebank_app/pages/transfers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Image.asset('assets/images/logo.png', height: 40),
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
