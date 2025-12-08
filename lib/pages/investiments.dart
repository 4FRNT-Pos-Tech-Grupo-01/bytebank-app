import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bytebank_app/app_colors.dart';

class Investiments extends StatelessWidget {
  const Investiments({super.key});

  Widget buildInvestmentChart() {
    final data = {
      "Fundo de investimento": 25.0,
      "Tesouro direto": 20.0,
      "Previdências": 30.0,
      "Bolsa de valores": 25.0,
    };

    final colors = [
      TransferScreenColors.investimentBlue,
      TransferScreenColors.investimentPurple,
      TransferScreenColors.investimentPink,
      TransferScreenColors.investimentOrange,
    ];

    int index = 0;

    final sections = data.entries.map((entry) {
      final section = PieChartSectionData(
        value: entry.value,
        color: colors[index % colors.length],
        radius: 40,
        title: "",
        titleStyle: const TextStyle(
          color: Colors.black,
          fontSize: 10,
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
                    .map((e) => e.copyWith(value: e.value * value))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildLegend() {
    final data = {
      "Fundo de investimento": TransferScreenColors.investimentBlue,
      "Tesouro direto": TransferScreenColors.investimentPurple,
      "Previdências": TransferScreenColors.investimentPink,
      "Bolsa de valores": TransferScreenColors.investimentOrange,
    };

    return data.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TransferScreenColors.containerBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Investimentos",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Total R\$ 50.000,00",
              style: TextStyle(
                color: TransferScreenColors.buttonBackground,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TransferScreenColors.buttonBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Renda fixa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "R\$ 36.000,00",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TransferScreenColors.buttonBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Renda variável",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "R\$ 14.000,00",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Estatísticas:",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TransferScreenColors.buttonBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildInvestmentChart(),
                  const SizedBox(height: 16),
                  const Text(
                    "Legenda:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
