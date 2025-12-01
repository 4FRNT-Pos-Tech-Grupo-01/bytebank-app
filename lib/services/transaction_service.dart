import 'dart:io';
import 'package:bytebank_app/constants/transfer.dart';
import 'package:bytebank_app/models/transfer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class TransactionService {
  DocumentSnapshot? _lastDocument;

  Future<List<TransactionModel>> fetchTransactions(
    int page, {
    TransactionType? type,
    double? minValue,
    double? maxValue,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(10);

    // Apply filters
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (minValue != null) {
      query = query.where('amount', isGreaterThanOrEqualTo: minValue);
    }

    if (maxValue != null) {
      query = query.where('amount', isLessThanOrEqualTo: maxValue);
    }

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      print('Fetched transaction data: $data');

      DateTime? date = data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : null;

      var month = date != null ? date.month.toString() : 'unknown';

      var fullDate = date != null
          ? '${date.day.toString().padLeft(2, '0')}/'
                '${date.month.toString().padLeft(2, '0')}/'
                '${date.year}'
          : 'unknown';

      return TransactionModel(
        id: doc.id,
        month: month,
        date: fullDate,
        value: (data['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere((e) => e.name == data['type']),
      );
    }).toList();
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

  Future<void> updateTransaction({
    required String id,
    required String type,
    required double amount,
    File? newAttachment,
    String? attachmentName,
  }) async {
    String? newPath;

    if (newAttachment != null) {
      newPath = await _saveFileLocally(newAttachment, attachmentName);
    }

    await FirebaseFirestore.instance.collection('transactions').doc(id).update({
      'type': type,
      'amount': amount,
      if (newPath != null) 'attachmentPath': newPath,
    });
  }

  Future<void> deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}
