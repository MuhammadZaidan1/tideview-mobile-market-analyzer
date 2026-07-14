import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tideview/core/database/user_prefs.dart';
import '../services/isar_service.dart';

class ExchangeRateNotifier extends AsyncNotifier<double> {
  late final IsarService _isarService;
  @override
  Future<double> build() async {
    _isarService = IsarService();
    final prefs = await _isarService.getUserPrefs();
    if (prefs != null && prefs.baseCurrency != 'USD') {
      Future.microtask(() => fetchAndUpdateRate(prefs.baseCurrency));
    }
    return prefs?.exchangeRate ?? 1.0;
  }
  Future<void> fetchAndUpdateRate(String targetCurrency) async {
    if (targetCurrency == 'USD') {
      await _saveRateToIsar(1.0);
      state = const AsyncValue.data(1.0);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final newRate = (rates[targetCurrency] as num?)?.toDouble() ?? 1.0;
        await _saveRateToIsar(newRate);
        state = AsyncValue.data(newRate);
      } else {
        final prefs = await _isarService.getUserPrefs();
        state = AsyncValue.data(prefs?.exchangeRate ?? 1.0);
      }
    } catch (e) {
      final prefs = await _isarService.getUserPrefs();
      state = AsyncValue.data(prefs?.exchangeRate ?? 1.0);
    }
  }
  Future<void> _saveRateToIsar(double rate) async {
    final isar = await _isarService.db;
    final prefs = await _isarService.getUserPrefs();
    if (prefs != null) {
      prefs.exchangeRate = rate;
      await isar.writeTxn(() async {
        await isar.userPrefs.put(prefs);
      });
    }
  }
}

final exchangeRateProvider =
    AsyncNotifierProvider<ExchangeRateNotifier, double>(() {
      return ExchangeRateNotifier();
    });
