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
  late String? selectedTransactionType;
  late TextEditingController amountController;

  void handleTransaction() {
    bool validTransaction =
        selectedTransactionType != null && amountController.text.isNotEmpty;

    if (validTransaction) {
      print('transaction type: $selectedTransactionType');
      print('amount: ${amountController.text}');
    } else {
      print('Invalid transaction data');
    }
  }

  @override
  void initState() {
    super.initState();
    selectedTransactionType = widget.initialTransactionType;
    amountController = widget.amountController ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: Column(
            children: [
              Text(
                'Nova Transação',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse('0xFF${titleFontColor.substring(1)}')),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Color(
                      int.parse('0xFF${buttonBackgroundColor.substring(1)}'),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTransactionType,
                    hint: const Text('Selecione o tipo de transação'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTransactionType = newValue!;
                      });
                    },
                    items: transferOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Valor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse('0xFF${titleFontColor.substring(1)}')),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(regexForAmount)),
                  ],
                  decoration: InputDecoration(
                    hintText: '00,00',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                          int.parse(
                            '0xFF${buttonBackgroundColor.substring(1)}',
                          ),
                        ),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                          int.parse(
                            '0xFF${buttonBackgroundColor.substring(1)}',
                          ),
                        ),
                        width: 1,
                      ),
                    ),
                  ),
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
