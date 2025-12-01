import 'dart:io';
import 'package:bytebank_app/validators/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bytebank_app/constants/transfer.dart';
import 'package:bytebank_app/app_colors.dart';
import 'package:bytebank_app/services/transaction_service.dart';

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
  String? selectedTransactionType;
  late TextEditingController amountController;
  File? selectedFile;
  String? selectedFileName;
  final TransactionService _service = TransactionService();

  @override
  void initState() {
    super.initState();
    selectedTransactionType = widget.initialTransactionType;
    amountController = widget.amountController ?? TextEditingController();
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        setState(() {
          selectedFile = File(file.path!);
          selectedFileName = file.name.isNotEmpty
              ? file.name
              : 'attachment_${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar arquivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar arquivo.')),
      );
    }
  }

  Future<void> handleTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText);
    if (amount == null || selectedTransactionType == null) return;

    final type =
        (selectedTransactionType == TransactionType.transfer ||
            selectedTransactionType == transferToDisplay)
        ? 'transfer'
        : 'deposit';

    await _service.createTransaction(
      type: type,
      amount: amount,
      attachment: selectedFile,
      attachmentName: selectedFileName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação concluída com sucesso!')),
    );

    amountController.clear();
    setState(() {
      selectedTransactionType = null;
      selectedFile = null;
      selectedFileName = null;
    });
  }

  @override
  void dispose() {
    if (widget.amountController == null) {
      amountController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: TransferScreenColors.containerBackground,
          image: const DecorationImage(
            image: AssetImage('assets/images/transaction-background.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
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
                      color: TransferScreenColors.titleFont,
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
                    onChanged: (value) =>
                        setState(() => selectedTransactionType = value),
                    validator: validateTransactionType,
                    items: transferOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Valor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TransferScreenColors.titleFont,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(regexForAmount),
                        ),
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
                      validator: validateAmount,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      Text(
                        'Anexo (opcional)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TransferScreenColors.titleFont,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickAttachment,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Selecionar arquivo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: TransferScreenColors.buttonBackground,
                            ),
                          ),
                        ),
                      ),
                      if (selectedFileName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Arquivo: $selectedFileName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
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
                      backgroundColor: TransferScreenColors.buttonBackground,
                      foregroundColor: TransferScreenColors.buttonFont,
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
      ),
    );
  }
}
