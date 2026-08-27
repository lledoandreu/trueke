import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/trade_offer.dart';

abstract class BaseTradeRepository {
  Future<List<TradeOffer>> fetchIncomingOffers();
  Future<List<TradeOffer>> fetchOutgoingOffers();
  Future<bool> updateOfferStatus(String offerId, String status);
}

class SupabaseTradeRepository implements BaseTradeRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TradeOffer>> fetchIncomingOffers() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      // Protección contra nulos automática:
      if (currentUserId == null) return [];

      final List<dynamic> response = await _supabase
          .from('trade_offers')
          .select()
          .eq('receiver_id', currentUserId);

      return response.map((json) => TradeOffer.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TradeOffer>> fetchOutgoingOffers() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      // Protección contra nulos automática:
      if (currentUserId == null) return [];

      final List<dynamic> response = await _supabase
          .from('trade_offers')
          .select()
          .eq('sender_id', currentUserId);

      return response.map((json) => TradeOffer.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> updateOfferStatus(String offerId, String status) async {
    try {
      await _supabase
          .from('trade_offers')
          .update({'status': status})
          .eq('id', offerId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
