import 'package:flutter/material.dart';

const containerBackgroundColor = '#CBCBCB';
const titleFontColor = '#DEE9EA';
const buttonBackgroundColor = '#004D61';
const buttonFontColor = '#FFFFFF';
const transferOptions = ['Depósito', 'Transferência'];

class Transfers extends StatefulWidget {
  const Transfers({super.key});

  @override
  State<Transfers> createState() => _TransfersState();
}

class _TransfersState extends State<Transfers> {
  String? selectedTransactionType;
  final TextEditingController amountController = TextEditingController();

  void handleTransaction() {
    print('transaction type: $selectedTransactionType');
    print('amount: ${amountController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(int.parse('0xFF${containerBackgroundColor.substring(1)}')),
      padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
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
                  dropdownColor: Colors.white, // background of dropdown menu
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
                decoration: InputDecoration(
                  hintText: '00,00',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(
                        int.parse('0xFF${buttonBackgroundColor.substring(1)}'),
                      ),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(
                        int.parse('0xFF${buttonBackgroundColor.substring(1)}'),
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
              child: const Text(
                'Concluir\ntransação',
                textAlign: TextAlign.center,
              ),
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
            ),
            const SizedBox(height: 32),
            Image.asset('images/transfer-woman.png', width: 280, height: 180),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
