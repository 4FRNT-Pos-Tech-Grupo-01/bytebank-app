import 'package:flutter/material.dart';
import 'package:bytebank_app/constants/transfer.dart';
import 'package:flutter/services.dart';

const containerBackgroundColor = '#CBCBCB';
const titleFontColor = '#DEE9EA';
const buttonBackgroundColor = '#004D61';
const buttonFontColor = '#FFFFFF';
const regexForAmount = r'^\d*[\.,]?\d{0,2}$';

class Transfers extends StatefulWidget {
  final String? initialTransactionType;
  final TextEditingController? amountController;

  const Transfers({
    super.key,
    this.initialTransactionType,
    this.amountController,
  });

  @override
  State<Transfers> createState() => _TransfersState();
}

class _TransfersState extends State<Transfers> {
  final _formKey = GlobalKey<FormState>();
  late String? selectedTransactionType;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    selectedTransactionType = widget.initialTransactionType;
    amountController = widget.amountController ?? TextEditingController();
  }

  String? _validateTransactionType(String? type) {
    if (type == null || !transferOptions.contains(type)) {
      return 'Selecione um tipo de transação válido';
    }
    return null;
  }

  String? _validateAmount(String? amountText) {
    if (amountText == null || amountText.trim().isEmpty) {
      return 'Informe um valor';
    }

    final cleanedAmount = amountText.replaceAll(',', '.').trim();
    final amount = double.tryParse(cleanedAmount);

    if (amount == null || amount <= 0) {
      return 'Digite um valor positivo';
    }

    return null;
  }

  void handleTransaction() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação enviada com sucesso!')),
      );
      print('transaction type: $selectedTransactionType');
      print('amount: ${amountController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF${containerBackgroundColor.substring(1)}')),
        image: const DecorationImage(
          image: AssetImage('assets/images/transaction-background.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
      child: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Nova Transação',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      int.parse('0xFF${titleFontColor.substring(1)}'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  initialValue: selectedTransactionType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: const Text('Selecione o tipo de transação'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTransactionType = newValue!;
                    });
                  },
                  validator: _validateTransactionType,
                  items: transferOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Text(
                  'Valor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      int.parse('0xFF${titleFontColor.substring(1)}'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(regexForAmount)),
                    ],
                    decoration: InputDecoration(
                      hintText: '00,00',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _validateAmount,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: handleTransaction,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Color(
                      int.parse('0xFF${buttonBackgroundColor.substring(1)}'),
                    ),
                    foregroundColor: Color(
                      int.parse('0xFF${buttonFontColor.substring(1)}'),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  child: const Text(
                    'Concluir\ntransação',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.amountController == null) {
      amountController.dispose();
    }
    super.dispose();
  }
}
