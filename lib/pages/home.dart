import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {

  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _DashboardHero();
}

class _DashboardHero extends State<Home> {
  bool _initialized = false;
  bool hideBalance = false;
  late Future<double> accountBalance;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    accountBalance = fetchBalance();
  }

  Future<void> _loadLocale() async {
    await initializeDateFormatting('pt_BR', null);
    setState(() => _initialized = true);
  }

  Future<double> fetchBalance() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('transactions').get();
    return calculateBalance(snapshot);
  }

  double calculateBalance(QuerySnapshot snapshot) {
    double total = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      final type = (data['type'] ?? '').toString().toLowerCase();

      if (type == 'deposit') {
        total += amount;
      } else if (type == 'transfer') {
        total -= amount;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final String currentLoggedUsername = "Felipe";
    final date = DateFormat("EEEE, dd/MM/yyyy", "pt_BR")
        .format(DateTime.now())
        .replaceFirstMapped(
          RegExp(r'^\w'),
          (m) => m[0]!.toUpperCase(),
        );

    return Container(
      width: double.infinity,
      height: 600.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF014A58),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Olá, $currentLoggedUsername! :)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Saldo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => hideBalance = !hideBalance);
                },
                child: Icon(
                  hideBalance
                      ? Icons.visibility_off_outlined
                      : Icons.remove_red_eye_outlined,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.4),
          ),

          const SizedBox(height: 16),
          const Text(
            "Conta Corrente",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          FutureBuilder<double>(
            future: accountBalance,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text(
                  "R\$ ...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              final balance = snapshot.data!;
              final formattedBalance = "R\$ ${balance.toStringAsFixed(2)}";

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 0),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  hideBalance ? "R\$ ••••••••••" : formattedBalance,
                  key: ValueKey(hideBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              '../assets/images/dashboard-image.png',
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}