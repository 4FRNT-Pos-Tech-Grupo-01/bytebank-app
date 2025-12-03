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

  TransactionType? _filterType;
  double? _minValue;
  double? _maxValue;

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
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final newData = await _service.fetchTransactionsInMemory(
      _page,
      type: _filterType,
      minValue: _minValue,
      maxValue: _maxValue,
    );

    // TODO: Remove once we use indexed fetching instead of in-memory and use only the newData variable
    final existingIds = transactions.map((t) => t.id).toSet();
    final uniqueNewData = newData
        .where((t) => !existingIds.contains(t.id))
        .toList();

    setState(() {
      transactions.addAll(uniqueNewData);
      _page++;
      _isLoading = false;
    });
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      transactions.clear();
      _page = 1;
    });

    _service.resetPagination();
    await _fetchTransactions();
  }

  void _openFilterSheet() {
    final minController = TextEditingController(
      text: _minValue?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: _maxValue?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        TransactionType? tempType = _filterType;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filtrar Transações',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: TransactionType.values.map((type) {
                      return ChoiceChip(
                        label: Text(
                          type == TransactionType.deposit
                              ? depositToDisplay
                              : transferToDisplay,
                        ),
                        selected: tempType == type,
                        onSelected: (selected) {
                          setModalState(() {
                            tempType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Valor mínimo',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Valor máximo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _filterType = null;
                              _minValue = null;
                              _maxValue = null;
                            });
                            _refreshTransactions();
                          },
                          child: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            setState(() {
                              _filterType = tempType;
                              _minValue = double.tryParse(
                                minController.text.trim(),
                              );
                              _maxValue = double.tryParse(
                                maxController.text.trim(),
                              );
                            });

                            _refreshTransactions();
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                const SizedBox(width: 16),
                InkWell(
                  onTap: _openFilterSheet,
                  child: const Icon(
                    Icons.filter_alt,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Transfers(),
                      ),
                    );

                    if (result == true) {
                      _refreshTransactions();
                    }
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

                  return TransactionTile(
                    transaction: transactions[index],
                    onRefreshParent: _refreshTransactions,
                  );
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
  final VoidCallback onRefreshParent;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onRefreshParent,
  });

  String get transactionValueToDisplay {
    return 'R\$ ${transaction.value.toStringAsFixed(2)}';
  }

  _deleteTransaction(BuildContext context) async {
    final service = TransactionService();

    try {
      await service.deleteTransaction(transaction.id);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transação deletada')));

      onRefreshParent();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao deletar transação: $e')));
    }
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
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Transfers(
                              id: transaction.id,
                              initialTransactionType: depositToDisplay,
                              amountController: TextEditingController(
                                text: transaction.value.toString(),
                              ),
                            ),
                          ),
                        );

                        if (result == true) {
                          onRefreshParent();
                        }
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
