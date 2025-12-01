import 'package:flutter/material.dart';
import 'package:bytebank_app/firebase_auth.dart';

class ResetCurrentPasswordPage extends StatefulWidget {
  const ResetCurrentPasswordPage({super.key});
  @override
  State<ResetCurrentPasswordPage> createState() =>
      _ResetCurrentPasswordPageState();
}

class _ResetCurrentPasswordPageState extends State<ResetCurrentPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
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

  Future<void> _update() async {
    final email = _emailController.text.trim();
    final current = _currentController.text;
    final neu = _newController.text;

    if (email.isEmpty || current.isEmpty || neu.isEmpty) {
      return _show('Preencha todos os campos');
    }

    if (neu.length < 6) {
      return _show('Nova senha precisa ter ao menos 6 caracteres');
    }

    setState(() => _loading = true);
    try {
      await Auth().resetPasswordFroCurrentPassword(
        email: email,
        currentPassword: current,
        newPassword: neu,
      );
      _show('Senha atualizada com sucesso');
      _currentController.clear();
      _newController.clear();
    } catch (e) {
      _show('Erro: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha (reauth)')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // === LOGO AQUI ===
            Image.asset('assets/images/logo.png', height: 120),

            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              decoration: _input('Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _currentController,
              decoration: _input('Senha atual'),
              obscureText: true,
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _newController,
              decoration: _input('Nova senha'),
              obscureText: true,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Atualizar senha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
