import 'package:bytebank_app/constants/transfer.dart';

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
