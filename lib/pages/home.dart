import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  final String currentLoggedUsername;
  final double accountBalance;

  const Home({
    super.key,
    required this.currentLoggedUsername,
    required this.accountBalance,
  });

  @override
  State<Home> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<Home> {
  bool _initialized = false;
  bool hideBalance = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    await initializeDateFormatting('pt_BR', null);
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final date = DateFormat("EEEE, dd/MM/yyyy", "pt_BR").format(DateTime.now());
    final String formattedBalance = "R\$ ${widget.accountBalance.toStringAsFixed(2).replaceAll('.', ',')}";

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
            "Olá, ${widget.currentLoggedUsername}! :)",
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
              fontSize: 12,
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
                  size: 20,
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
          AnimatedSwitcher(
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
