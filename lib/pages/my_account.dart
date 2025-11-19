import 'package:flutter/material.dart';

class MyAccount extends StatelessWidget {
  final VoidCallback? onBack;

  const MyAccount({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Página de Minha Conta'),
      ),
    );
  }
}