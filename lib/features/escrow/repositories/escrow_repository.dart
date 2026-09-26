import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/escrow_transaction.dart';

abstract class EscrowRepository {
  Future<EscrowTransaction> getEscrowByTradeOfferId(String tradeOfferId);
  Future<EscrowTransaction> createEscrow({
    required String tradeOfferId,
    required double amount,
    required String currency,
  });
  Future<EscrowTransaction> updateTrackingInfo({
    required String escrowId,
    required String trackingNumber,
    required String carrier,
  });
}

class SupabaseEscrowRepository implements EscrowRepository {
  final SupabaseClient _supabaseClient;

  SupabaseEscrowRepository(this._supabaseClient);

  @override
  Future<EscrowTransaction> getEscrowByTradeOfferId(String tradeOfferId) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .select()
        .eq('trade_offer_id', tradeOfferId)
        .single();
    return EscrowTransaction.fromJson(response);
  }

  @override
  Future<EscrowTransaction> createEscrow({
    required String tradeOfferId,
    required double amount,
    required String currency,
  }) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .insert({
          'trade_offer_id': tradeOfferId,
          'amount': amount,
          'currency': currency,
          'status': 'pending_deposit',
        })
        .select()
        .single();
    return EscrowTransaction.fromJson(response);
  }

  @override
  Future<EscrowTransaction> updateTrackingInfo({
    required String escrowId,
    required String trackingNumber,
    required String carrier,
  }) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .update({
          'tracking_number': trackingNumber,
          'carrier': carrier,
          'status': 'shipped',
        })
        .eq('id', escrowId)
        .select()
        .single();
    return EscrowTransaction.fromJson(response);
  }
}

final escrowRepositoryProvider = Provider<EscrowRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseEscrowRepository(supabaseClient);
});
