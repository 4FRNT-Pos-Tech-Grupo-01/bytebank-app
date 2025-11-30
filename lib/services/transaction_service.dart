import 'dart:io';
import 'package:bytebank_app/constants/transfer.dart';
import 'package:bytebank_app/models/transfer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class TransactionService {
  Future<List<TransactionModel>> fetchTransactions(
    int page, {
    TransactionType? type,
    double? minValue,
    double? maxValue,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final data = List.generate(10, (index) {
      return TransactionModel(
        month: "Mês $page",
        date: "01/01/2025",
        value: ((index + (page * 10)) * 100).toDouble(),
        type: index % 2 == 0
            ? TransactionType.deposit
            : TransactionType.transfer,
      );
    });

    final filtered = data.where((t) {
      if (type != null && t.type != type) return false;
      if (minValue != null && t.value < minValue) return false;
      if (maxValue != null && t.value > maxValue) return false;
      return true;
    }).toList();

    return filtered;
  }

  Future<String?> _saveFileLocally(File file, String? fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name =
          fileName ?? 'attachment_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '${directory.path}/$name';

      final savedFile = await file.copy(filePath);
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> createTransaction({
    required String type,
    required double amount,
    File? attachment,
    String? attachmentName,
  }) async {
    final localFilePath = attachment != null
        ? await _saveFileLocally(attachment, attachmentName)
        : null;

    await FirebaseFirestore.instance.collection('transactions').add({
      'type': type,
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
      'attachmentPath': localFilePath,
    });
  }
}
