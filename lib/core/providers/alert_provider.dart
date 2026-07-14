import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/price_alert.dart';
import '../services/isar_service.dart';

class AlertNotifier extends AsyncNotifier<List<PriceAlert>> {
  late final IsarService _isarService;
  StreamSubscription? _subscription;

  @override
  Future<List<PriceAlert>> build() async {
    _isarService = IsarService();
    final initialAlerts = await _fetchAlerts();
    final isar = await _isarService.db;
    _subscription = isar.priceAlerts.watchLazy(fireImmediately: false).listen((
      _,
    ) {
      loadAlerts();
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return initialAlerts;
  }

  Future<List<PriceAlert>> _fetchAlerts() async {
    return await _isarService.getAllPriceAlerts();
  }

  Future<void> loadAlerts() async {
    state = const AsyncValue.loading();
    try {
      final alerts = await _fetchAlerts();
      state = AsyncValue.data(alerts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleAlert(int id) async {
    await _isarService.togglePriceAlert(id);
  }

  Future<void> deleteAlert(int id) async {
    await _isarService.deletePriceAlert(id);
  }

  Future<void> addAlert(String symbol, double targetPrice, bool isAbove) async {
    final alert = PriceAlert()
      ..symbol = symbol
      ..targetPrice = targetPrice
      ..isAbove = isAbove
      ..isActive = true;
    await _isarService.savePriceAlert(alert);
  }
}

final alertProvider = AsyncNotifierProvider<AlertNotifier, List<PriceAlert>>(
  () {
    return AlertNotifier();
  },
);
