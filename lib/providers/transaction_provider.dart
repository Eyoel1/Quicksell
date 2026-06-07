import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../services/firebase_transaction_service.dart';

final transactionServiceProvider =
    Provider((ref) => FirebaseTransactionService());

final userTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, String>((ref, userId) {
  return ref.watch(transactionServiceProvider).transactionsForUserStream(userId);
});
