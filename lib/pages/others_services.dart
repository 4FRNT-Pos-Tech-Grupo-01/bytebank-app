import 'package:flutter/material.dart';
import 'package:bytebank_app/firebase_auth.dart';

class AccountServicesPage extends StatefulWidget {
  const AccountServicesPage({super.key});

  @override
  State<AccountServicesPage> createState() => _AccountServicesPageState();
}

class _AccountServicesPageState extends State<AccountServicesPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _deletePasswordController =
      TextEditingController();

  bool _loading = false;

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _updateUsername() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) return _show('Informe o novo nome de usuário');
    setState(() => _loading = true);
    try {
      await Auth().updateUsername(displayName: name);
      _show('Nome atualizado com sucesso');
      _displayNameController.clear();
    } catch (e) {
      _show('Erro ao atualizar nome: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return _show('Informe o email');
    setState(() => _loading = true);
    try {
      await Auth().resetPassword(email: email);
      _show('Email de recuperação enviado');
    } catch (e) {
      _show('Erro ao enviar email: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetCurrentPassword() async {
    final email = _emailController.text.trim();
    final current = _currentPasswordController.text;
    final neu = _newPasswordController.text;
    if (email.isEmpty || current.isEmpty || neu.isEmpty)
      return _show('Preencha email, senha atual e nova senha');
    if (neu.length < 6)
      return _show('Nova senha deve ter ao menos 6 caracteres');
    setState(() => _loading = true);
    try {
      await Auth().resetPasswordFroCurrentPassword(
        email: email,
        currentPassword: current,
        newPassword: neu,
      );
      _show('Senha atualizada com sucesso');
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      _show('Erro ao atualizar senha: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final email = _emailController.text.trim();
    final password = _deletePasswordController.text;
    if (email.isEmpty || password.isEmpty)
      return _show('Informe email e senha para excluir');
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
      await Auth().deleteAccount(email: email, password: password);
      _show('Conta excluída. Você será deslogado.');
      // após exclusão, normalmente o app redireciona para login; aqui apenas limpa campos
      _emailController.clear();
      _deletePasswordController.clear();
    } catch (e) {
      _show('Erro ao excluir conta: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços da conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Email (usar para reset / delete)'),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const Divider(),

            _sectionTitle('Enviar email de recuperação'),
            ElevatedButton(
              onPressed: _loading ? null : _sendResetEmail,
              child: const Text('Enviar email de recuperação'),
            ),

            const Divider(),

            _sectionTitle('Reset senha (reauth + update)'),
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Senha atual'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'Nova senha'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _resetCurrentPassword,
              child: const Text('Atualizar senha'),
            ),

            const Divider(),

            _sectionTitle('Atualizar nome de usuário (displayName)'),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Novo nome de usuário',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _updateUsername,
              child: const Text('Atualizar nome'),
            ),

            const Divider(),

            _sectionTitle('Excluir conta'),
            TextField(
              controller: _deletePasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha para confirmar',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _loading ? null : _deleteAccount,
              child: const Text('Excluir conta'),
            ),
          ],
        ),
      ),
    );
  }
}
