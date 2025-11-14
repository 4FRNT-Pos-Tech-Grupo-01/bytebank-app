import 'package:bytebank_app/constants/transfer.dart';
import 'package:bytebank_app/pages/transfers.dart';
import 'package:flutter/material.dart';

const background = Color(0xFFF4F4F4);
const green = Color(0xFF47A138);

class BankStatement extends StatelessWidget {
  BankStatement({super.key});

  final transaction = TransactionModel(
    month: "Dezembro",
    date: "05/12/2025",
    value: "R\$ 4.000,00",
    type: TransactionType.deposit,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Extrato',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TransactionTile(transaction: transaction),
          ],
        ),
      ),
    );
  }
}

class TransactionModel {
  final String month;
  final String date;
  final String value;
  final TransactionType type;

  TransactionModel({
    required this.month,
    required this.date,
    required this.value,
    required this.type,
  });
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: green, width: 1.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  transaction.month,
                  style: const TextStyle(
                    color: green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Transfers(
                              initialTransactionType: depositToDisplay,
                              amountController: TextEditingController(
                                text: transaction.value.replaceAll("R\$ ", ""),
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        print("Del tapped");
                      },
                      child: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  transaction.type == TransactionType.deposit
                      ? depositToDisplay
                      : transferToDisplay,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  transaction.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              transaction.value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
