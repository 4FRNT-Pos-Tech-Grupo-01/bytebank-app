import 'package:bytebank_app/app_colors.dart';
import 'package:bytebank_app/constants/transfer.dart';
import 'package:bytebank_app/models/transfer.dart';
import 'package:bytebank_app/pages/transfers.dart';
import 'package:bytebank_app/services/transaction_service.dart';
import 'package:flutter/material.dart';

class BankStatement extends StatefulWidget {
  const BankStatement({super.key});

  @override
  State<BankStatement> createState() => _BankStatementState();
}

class _BankStatementState extends State<BankStatement> {
  final List<TransactionModel> transactions = [];
  final ScrollController _scrollController = ScrollController();
  final TransactionService _service = TransactionService();

  bool _isLoading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _fetchTransactions();
      }
    });
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });

    final newData = await _service.fetchTransactions(_page);

    setState(() {
      transactions.addAll(newData);
      _page++;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TransferScreenColors.statementBackground,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Extrato',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Transfers(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, size: 32, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: transactions.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == transactions.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return TransactionTile(transaction: transactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  String get transactionValueToDisplay {
    return 'R\$ ${transaction.value.toStringAsFixed(2)}';
  }

  _deleteTransaction(BuildContext context) async {
    final service = TransactionService();

    await service.deleteTransaction(transaction.id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transação deletada')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: TransferScreenColors.statementGreen,
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  transaction.month,
                  style: const TextStyle(
                    color: TransferScreenColors.statementGreen,
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
                                text: transaction.value.toString(),
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: const Text(
                                'Tem certeza que deseja deletar esta transação?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteTransaction(context);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Deletar'),
                                ),
                              ],
                            );
                          },
                        );
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
              transactionValueToDisplay,
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
