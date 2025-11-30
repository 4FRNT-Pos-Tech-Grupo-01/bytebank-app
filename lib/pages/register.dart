import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  bool _loading = false;

  Future<void> _createUserWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();
    final userName = _userNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    // Validação: email válido
    final emailRegex = RegExp(r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$");
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um email válido')),
      );
      return;
    }

    // Validação: username não pode conter espaços
    if (userName.contains(RegExp(r'\s'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome de usuário não pode conter espaços'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Cria o usuário no Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Pega o UID (pode vir de userCredential.user ou do FirebaseAuth)
      final uid =
          userCredential.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Erro ao obter UID do usuário');

      // Grava dados adicionais no Firestore na coleção 'users' com doc id = uid
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'fullName': fullName,
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'Erro ao criar a conta';
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Image.asset('assets/images/logo.png', height: 24)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Crie sua conta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // centraliza verticalmente
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(195, 41, 202, 27),
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(195, 41, 202, 27),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        cursorColor: Color.fromARGB(195, 41, 202, 27),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(195, 41, 202, 27),
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(195, 41, 202, 27),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        obscureText: true,
                        cursorColor: Color.fromARGB(195, 41, 202, 27),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(195, 41, 202, 27),
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(195, 41, 202, 27),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        cursorColor: Color.fromARGB(195, 41, 202, 27),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _userNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome de usuário',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(195, 41, 202, 27),
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(195, 41, 202, 27),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        cursorColor: Color.fromARGB(195, 41, 202, 27),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : _createUserWithEmailAndPassword,
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
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Criar conta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
