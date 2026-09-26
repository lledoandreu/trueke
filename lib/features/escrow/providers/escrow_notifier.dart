import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/escrow_repository.dart';
import 'escrow_state.dart';

class EscrowNotifier extends Notifier<EscrowState> {
  final String tradeOfferId;
  late final EscrowRepository _repository;

  EscrowNotifier(this.tradeOfferId);

  @override
  EscrowState build() {
    _repository = ref.watch(escrowRepositoryProvider);
    return const EscrowInitial();
  }

  Future<void> fetchEscrowByTradeOfferId() async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.getEscrowByTradeOfferId(
        tradeOfferId,
      );
      state = EscrowLoaded(transaction);
    } catch (e) {
      state = const EscrowError('Error al cargar la transacción en custodia');
    }
  }

  Future<void> initializeEscrow({
    required double amount,
    required String currency,
  }) async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.createEscrow(
        tradeOfferId: tradeOfferId,
        amount: amount,
        currency: currency,
      );
      state = EscrowLoaded(transaction);
    } catch (e) {
      state = const EscrowError('Error al inicializar el depósito seguro');
    }
  }

  Future<void> addTrackingLogistics({
    required String escrowId,
    required String trackingNumber,
    required String carrier,
  }) async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.updateTrackingInfo(
        escrowId: escrowId,
        trackingNumber: trackingNumber,
        carrier: carrier,
      );
      state = EscrowLoaded(transaction);
    } catch (e) {
      state = const EscrowError('Error al actualizar la información de envío');
    }
  }
}

// En Riverpod 3 traditional family, la firma de inicializacion recibe solo el argumento
final escrowNotifierProvider =
    NotifierProvider.family<EscrowNotifier, EscrowState, String>(
      (arg) => EscrowNotifier(arg),
    );
