import 'dart:convert';
import 'package:isar/isar.dart';
import '../database/chart_cache.dart';
import '../services/supabase_service.dart';

// CATATAN MIGRASI: sama seperti crypto_repository.dart -- public method
// dipertahankan sama persis, cuma sumber data internalnya pindah dari
// Frankfurter/Yahoo Finance langsung ke Supabase.
class ForexRepository {
  Future<List<Map<String, dynamic>>> fetchForexMarkets() async {
    try {
      final response = await supabase
          .from('assets')
          .select('symbol, name, current_price, price_change_24h')
          .eq('market_type', 'forex');

      if (response.isEmpty) {
        throw Exception('Data assets forex dari Supabase kosong');
      }

      return response.map<Map<String, dynamic>>((row) {
        return {
          'symbol': row['symbol'],
          'name': row['name'],
          'current_price': (row['current_price'] as num?)?.toDouble() ?? 0.0,
          'price_change_percentage_24h':
              (row['price_change_24h'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error ambil data forex dari Supabase: $e');
    }
  }

  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    final isar = Isar.getInstance();
    final cacheKey = '${symbol}_$timeframe';

    if (isar != null) {
      try {
        final cachedChart = await isar.chartCaches
            .filter()
            .cacheKeyEqualTo(cacheKey)
            .findFirst();
        if (cachedChart != null &&
            DateTime.now().difference(cachedChart.lastUpdated).inMinutes < 30) {
          final List<dynamic> decoded = json.decode(cachedChart.pricesJson);
          return decoded
              .map(
                (e) =>
                    (e as List).cast<num>().map((n) => n.toDouble()).toList(),
              )
              .toList();
        }
      } catch (e) {
        // Silently fail
      }
    }

    try {
      final formattedPrices = await fetchChartDataFromEdgeFunction(
        symbol: symbol,
        marketType: 'forex',
        timeframe: timeframe,
      );

      if (isar != null && formattedPrices.isNotEmpty) {
        final newCache = ChartCache()
          ..cacheKey = cacheKey
          ..pricesJson = json.encode(formattedPrices)
          ..lastUpdated = DateTime.now();
        await isar.writeTxn(() async {
          await isar.chartCaches.put(newCache);
        });
      }

      return formattedPrices;
    } catch (e) {
      // Silently fail, sama seperti behaviour lama
    }
    return [];
  }
}
