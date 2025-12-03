import 'package:flutter/material.dart';
import 'package:bytebank_app/firebase_auth.dart';

class UpdateUsernamePage extends StatefulWidget {
  const UpdateUsernamePage({super.key});
  @override
  State<UpdateUsernamePage> createState() => _UpdateUsernamePageState();
}

class _UpdateUsernamePageState extends State<UpdateUsernamePage> {
  final TextEditingController _nameController = TextEditingController();
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

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) return _show('Informe o novo nome de usuário');
    if (name.contains(RegExp(r'\s'))) {
      return _show('Nome de usuário não pode conter espaços');
    }

    setState(() => _loading = true);

    try {
      await Auth().updateUsername(displayName: name);
      _show('Nome atualizado com sucesso');
      _nameController.clear();
    } catch (e) {
      _show('Erro: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atualizar nome de usuário')),

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
              controller: _nameController,
              decoration: _input('Novo nome de usuário'),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Atualizar nome'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
