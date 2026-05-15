import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../database/chart_cache.dart';

class ForexRepository {
  final String baseUrl = 'https://api.frankfurter.app';
  final Map<String, String> _currencyNames = {
    'EUR': 'Euro',
    'JPY': 'Japanese Yen',
    'GBP': 'British Pound',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'HKD': 'Hong Kong Dollar',
    'NZD': 'New Zealand Dollar',
    'SGD': 'Singapore Dollar',
    'IDR': 'Indonesian Rupiah',
    'MYR': 'Malaysian Ringgit',
    'THB': 'Thai Baht',
    'INR': 'Indian Rupee',
    'KRW': 'South Korean Won',
    'PHP': 'Philippine Peso',
    'ZAR': 'South African Rand',
    'BRL': 'Brazilian Real',
    'MXN': 'Mexican Peso',
  };

  Future<List<Map<String, dynamic>>> fetchForexMarkets() async {
    try {
      final url = Uri.parse('$baseUrl/latest?from=USD');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData is! Map<String, dynamic>) {
          throw FormatException('Expected JSON object dari Frankfurter');
        }

        final rates = decodedData['rates'];

        if (rates is! Map<String, dynamic> || rates.isEmpty) {
          throw Exception('Data rates tidak valid atau kosong');
        }

        final result = <Map<String, dynamic>>[];

        for (final entry in rates.entries) {
          final rateValue = entry.value;

          if (rateValue is! num || rateValue <= 0) {
            continue;
          }

          final price = (rateValue as num).toDouble();

          result.add({
            'symbol': entry.key,
            'name': _currencyNames[entry.key] ?? '${entry.key} Currency',
            'current_price': 1 / price,
            'price_change_percentage_24h': 0.0,
          });
        }

        return result;
      } else {
        throw Exception('Gagal narik data Frankfurter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error API Forex: $e');
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

    final yahooSymbol = '${symbol}USD=X';
    String range;
    String interval;

    switch (timeframe) {
      case '1D':
        range = '1d';
        interval = '15m';
        break;
      case '1W':
        range = '5d';
        interval = '60m';
        break;
      case '1M':
        range = '1mo';
        interval = '1d';
        break;
      case '3M':
        range = '3mo';
        interval = '1d';
        break;
      case '1Y':
        range = '1y';
        interval = '1wk';
        break;
      case 'ALL':
      default:
        range = '5y';
        interval = '1mo';
        break;
    }

    try {
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$yahooSymbol?range=$range&interval=$interval',
      );

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['chart']?['result'];

        if (result != null && result.isNotEmpty) {
          final timestamps = result[0]['timestamp'] as List<dynamic>?;
          final quote = result[0]['indicators']?['quote']?[0];
          final closes = quote?['close'] as List<dynamic>?;

          if (timestamps != null &&
              closes != null &&
              timestamps.length == closes.length &&
              timestamps.isNotEmpty) {
            final List<List<double>> formattedPrices = [];
            for (int i = 0; i < timestamps.length; i++) {
              if (closes[i] != null) {
                formattedPrices.add([
                  (timestamps[i] as num).toDouble() * 1000,
                  (closes[i] as num).toDouble(),
                ]);
              }
            }

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
          }
        }
      } else {
        // Silently fail
      }
    } catch (e) {
      // Silently fail
    }
    return [];
  }
}
