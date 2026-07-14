import 'dart:convert';
import 'package:isar/isar.dart';
import '../database/chart_cache.dart';
import '../services/supabase_service.dart';

// CATATAN MIGRASI: repository ini dulu hit Binance API langsung dari client.
// Sekarang data harga diambil dari table `assets` di Supabase (yang diisi
// server-side oleh Edge Function sync-markets tiap 15 menit), dan historical
// chart diambil dari Edge Function get-chart-data.
//
// Public method (fetchCryptoMarkets, fetchHistoricalData) DIPERTAHANKAN
// persis sama signature & shape return-nya, jadi market_sync_usecase.dart,
// background_service.dart, dan semua screen yang manggil ini TIDAK PERLU
// diubah sama sekali.
class CryptoRepository {
  Future<List<Map<String, dynamic>>> fetchCryptoMarkets() async {
    try {
      final response = await supabase
          .from('assets')
          .select('symbol, name, current_price, price_change_24h, image')
          .eq('market_type', 'crypto');

      if (response.isEmpty) {
        throw Exception('Data assets crypto dari Supabase kosong');
      }

      return response.map<Map<String, dynamic>>((row) {
        return {
          'symbol': row['symbol'],
          'name': row['name'],
          'current_price': (row['current_price'] as num?)?.toDouble() ?? 0.0,
          'price_change_percentage_24h':
              (row['price_change_24h'] as num?)?.toDouble() ?? 0.0,
          'image': row['image'], // sekarang beneran keisi, dari CoinGecko
        };
      }).toList();
    } catch (e) {
      throw Exception('Error ambil data crypto dari Supabase: $e');
    }
  }

  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    final isar = Isar.getInstance();
    final upperSymbol = symbol.toUpperCase();
    final cacheKey = '${upperSymbol}_$timeframe';
    if ([
      'USDT',
      'USDC',
      'DAI',
      'FDUSD',
      'USDD',
      'TUSD',
      'USDE',
      'PYUSD',
      'USDS',
      'FRAX',
      'GUSD',
      'USDP',
      'USD1',
    ].contains(upperSymbol)) {
      return [];
    }

    // Cek cache lokal Isar dulu (sama seperti logic lama) -- kalau fresh,
    // gak perlu hit Edge Function sama sekali.
    if (isar != null) {
      final cachedChart = await isar.chartCaches
          .where()
          .cacheKeyEqualTo(cacheKey)
          .findFirst();
      if (cachedChart != null &&
          DateTime.now().difference(cachedChart.lastUpdated).inMinutes < 30) {
        try {
          final List<dynamic> decoded = json.decode(cachedChart.pricesJson);
          return decoded
              .map(
                (e) =>
                    (e as List).cast<num>().map((n) => n.toDouble()).toList(),
              )
              .toList();
        } catch (e) {
          // Silently fail
        }
      }
    }

    try {
      final formattedPrices = await fetchChartDataFromEdgeFunction(
        symbol: upperSymbol,
        marketType: 'crypto',
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
      throw Exception('Error API Historical Data: $e');
    }
  }
}
