import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import 'package:trueke/features/offers/providers/trade_offer_provider.dart';
import 'package:trueke/features/offers/presentation/widgets/trade_offer_card_widget.dart';

class TradeOffersScreen extends ConsumerWidget {
  const TradeOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(userTradeOffersProvider);
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Intercambios Directos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: offersAsync.when(
        data: (offers) {
          if (currentUser == null) {
            return const Center(
              child: Text('Inicia sesión para ver tus ofertas.'),
            );
          }
          if (offers.isEmpty) {
            return const Center(
              child: Text(
                'No tienes propuestas de trueque pendientes.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return TradeOfferCard(
                offer: offer,
                currentUserId: currentUser.id,
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(
          child: Text(
            'Error al cargar las ofertas: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
