import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/transaction.dart';

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository(this._supabase);

  Future<void> createTransaction(ProductTransaction transaction) async {
    await _supabase.from('transactions').insert(transaction.toJson());
  }

  Future<List<ProductTransaction>> getUserTransactions(String userId) async {
    final response = await _supabase
        .from('transactions')
        .select()
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductTransaction.fromJson(json))
        .toList();
  }

  Future<void> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {
    await _supabase
        .from('transactions')
        .update({'status': status})
        .eq('id', transactionId);
  }
}
