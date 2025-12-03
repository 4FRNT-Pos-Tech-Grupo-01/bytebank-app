import 'package:flutter/material.dart';
import 'package:bytebank_app/firebase_auth.dart';

class ResetByEmailPage extends StatefulWidget {
  const ResetByEmailPage({super.key});
  @override
  State<ResetByEmailPage> createState() => _ResetByEmailPageState();
}

class _ResetByEmailPageState extends State<ResetByEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  final Color primaryGreen = const Color.fromARGB(195, 41, 202, 27);

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryGreen),
    ),
  );

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return _show('Informe o email');

    setState(() => _loading = true);
    try {
      await Auth().resetPassword(email: email);
      _show('Email de recuperação enviado');
      _emailController.clear();
    } catch (e) {
      _show('Erro: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar email de recuperação')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // === LOGO ADICIONADA AQUI ===
            Image.asset('assets/images/logo.png', height: 120),

            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              decoration: _input('Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
