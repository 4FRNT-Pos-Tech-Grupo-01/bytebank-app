import 'package:bytebank_app/constants/transfer.dart';

class TransactionModel {
  final String id;
  final String month;
  final String date;
  final double value;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.month,
    required this.date,
    required this.value,
    required this.type,
  });
}
