import 'package:bytebank_app/constants/transfer.dart';

const regexForAmount = r'^\d*[\.,]?\d{0,2}$';

String? validateTransactionType(String? type) {
  if (type == null || !transferOptions.contains(type)) {
    return 'Selecione um tipo de transação válido';
  }
  return null;
}

String? validateAmount(String? amountText) {
  if (amountText == null || amountText.trim().isEmpty) {
    return 'Informe um valor';
  }
  final cleanedAmount = amountText.replaceAll(',', '.').trim();
  final amount = double.tryParse(cleanedAmount);
  if (amount == null || amount <= 0) return 'Digite um valor positivo';
  return null;
}
