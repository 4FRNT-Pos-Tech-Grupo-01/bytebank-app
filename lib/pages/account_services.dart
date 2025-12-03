import 'package:flutter/material.dart';
import 'package:bytebank_app/pages/account_services/reset_by_email.dart';
import 'package:bytebank_app/pages/account_services/reset_current_password.dart';
import 'package:bytebank_app/pages/account_services/update_username_page.dart';
import 'package:bytebank_app/pages/account_services/delete_account_page.dart';

class AccountServicesPage extends StatefulWidget {
  const AccountServicesPage({super.key});

  @override
  State<AccountServicesPage> createState() => _AccountServicesPageState();
}

class _AccountServicesPageState extends State<AccountServicesPage> {
  final Color primaryGreen = const Color.fromARGB(195, 41, 202, 27);
  final bool _loading = false;

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: primaryGreen, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === LOGO CENTRALIZADA ===
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 30),

                // === CARD DOS SERVIÇOS ===
                Card(
                  elevation: 4,
                  shadowColor: primaryGreen.withOpacity(.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _menuTile(
                        context,
                        icon: Icons.email,
                        title: 'Enviar email de recuperação',
                        page: const ResetByEmailPage(),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      _menuTile(
                        context,
                        icon: Icons.lock,
                        title: 'Alterar senha (reauth)',
                        page: const ResetCurrentPasswordPage(),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      _menuTile(
                        context,
                        icon: Icons.person,
                        title: 'Atualizar nome de usuário',
                        page: const UpdateUsernamePage(),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      _menuTile(
                        context,
                        icon: Icons.delete_forever,
                        title: 'Excluir conta',
                        page: const DeleteAccountPage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: _loading ? const CircularProgressIndicator() : null,
    );
  }
}
