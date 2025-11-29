// ignore_for_file: avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class Home extends StatefulWidget {

  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _Finantials();
}

class _Finantials extends State<Home> {
  bool _initialized = false;
  bool hideBalance = false;
  late Future<double> accountBalance;
  late Future<Map<String, double>> chartData;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadUserData();
    accountBalance = fetchBalance();
    chartData = fetchChartData();
  }

  Future<Map<String, double>> fetchChartData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('transactions').get();

    double deposits = 0;
    double transfers = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final type = (data['type'] ?? '').toString().toLowerCase();

      if (type == 'deposit') {
        deposits += amount;
      } else if (type == 'transfer') {
        transfers += amount;
      }
    }

    return {
      "Depósitos": deposits,
      "Transferências": transfers.abs(),
    };
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

  Future<String> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Nenhum usuário logado");
    }

    return user.email ?? '';
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

  Widget buildBalanceChart(Map<String, double> data) {
    final colors = [
      const Color(0xFF014A58).withValues(alpha: 0.5),
      Colors.blueGrey[100],
    ];

    int index = 0;

    final sections = data.entries.map((entry) {
      final section = PieChartSectionData(
        value: entry.value,
        color: colors[index % colors.length],
        radius: 40,
        title: entry.key == "Depósitos"
            ? "Entradas R\$ ${entry.value.toStringAsFixed(2)}"
            : "Saídas R\$ ${entry.value.toStringAsFixed(2)}",
        titleStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      index++;
      return section;
    }).toList();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          height: 220,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: sections
                    .map(
                      (e) => e.copyWith(
                        value: e.value * value,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final date = DateFormat("EEEE, dd/MM/yyyy", "pt_BR")
        .format(DateTime.now())
        .replaceFirstMapped(
          RegExp(r'^\w'),
          (m) => m[0]!.toUpperCase(),
        );

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
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
                FutureBuilder<String>(
                  future: _loadUserData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading...");
                    }

                    return Text(
                      "Olá, ${snapshot.data}! :)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
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
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: FutureBuilder<Map<String, double>>(
              future: chartData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resumo Financeiro",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildBalanceChart(snapshot.data!),
                  ],
                );
              },
            ),
          ),
        ],
      )
    );
  }
}