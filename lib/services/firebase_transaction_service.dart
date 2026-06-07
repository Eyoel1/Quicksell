import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class FirebaseTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> transactionsForUserStream(String userId) {
    return _firestore
        .collection('transactions')
        .where(Filter.or(
          Filter('buyerId', isEqualTo: userId),
          Filter('sellerId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map((doc) =>
              TransactionModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return transactions;
    });
  }

  Future<void> confirmReceived(TransactionModel transaction) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('transactions').doc(transaction.id), {
      'status': TransactionStatus.completed.name,
      'completedAt': DateTime.now().toIso8601String(),
    });
    batch.update(_firestore.collection('products').doc(transaction.productId), {
      'status': ProductStatus.sold.name,
    });
    await batch.commit();
  }

  Future<void> cancelTransaction(TransactionModel transaction) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('transactions').doc(transaction.id), {
      'status': TransactionStatus.cancelled.name,
    });
    batch.update(_firestore.collection('products').doc(transaction.productId), {
      'status': ProductStatus.available.name,
    });
    await batch.commit();
  }
}
