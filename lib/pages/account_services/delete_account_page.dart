import 'package:flutter/material.dart';
import 'package:bytebank_app/firebase_auth.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});
  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  Future<void> _delete() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    if (email.isEmpty || pass.isEmpty) return _show('Informe email e senha');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Deseja realmente excluir sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    setState(() => _loading = true);

    try {
      await Auth().deleteAccount(email: email, password: pass);
      _show('Conta excluída com sucesso');
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      _show('Erro: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Excluir conta')),
      body: SingleChildScrollView(
        // evita overflow com teclado
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
            const SizedBox(height: 8),

            TextField(
              controller: _passwordController,
              decoration: _input('Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _delete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Excluir conta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
