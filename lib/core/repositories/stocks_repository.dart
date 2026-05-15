import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../database/chart_cache.dart';
import '../env/env.dart';

class StocksRepository {
  final String baseUrl = 'https://finnhub.io/api/v1';
  final String apiKey = Env.finnhubApiKey;

  final List<String> top50Stocks = [
    'AAPL',
    'MSFT',
    'NVDA',
    'GOOGL',
    'AMZN',
    'META',
    'TSLA',
    'NFLX',
    'SBUX',
    'MCD',
    'NKE',
    'KO',
    'DIS',
    'INTC',
    'AMD',
    'WMT',
    'JNJ',
    'V',
    'PG',
    'JPM',
    'UNH',
    'HD',
    'MA',
    'BAC',
    'XOM',
    'CVX',
    'LLY',
    'ABBV',
    'MRK',
    'PEP',
    'AVGO',
    'COST',
    'ORCL',
    'ADBE',
    'CRM',
    'CSCO',
    'ACN',
    'WFC',
    'PM',
    'COP',
    'QCOM',
    'BA',
    'IBM',
    'CAT',
    'GE',
    'F',
    'GM',
    'MMM',
    'T',
    'VZ',
  ];

  final Map<String, String> _stockNames = {
    'AAPL': 'Apple',
    'MSFT': 'Microsoft',
    'NVDA': 'NVIDIA',
    'GOOGL': 'Alphabet',
    'AMZN': 'Amazon',
    'META': 'Meta',
    'TSLA': 'Tesla',
    'NFLX': 'Netflix',
    'SBUX': 'Starbucks',
    'MCD': 'McDonald\'s',
    'NKE': 'Nike',
    'KO': 'Coca-Cola',
    'DIS': 'Disney',
    'INTC': 'Intel',
    'AMD': 'AMD',
    'WMT': 'Walmart',
    'JNJ': 'Johnson & Johnson',
    'V': 'Visa',
    'PG': 'Procter & Gamble',
    'JPM': 'JPMorgan Chase',
    'UNH': 'UnitedHealth',
    'HD': 'Home Depot',
    'MA': 'Mastercard',
    'BAC': 'Bank of America',
    'XOM': 'Exxon Mobil',
    'CVX': 'Chevron',
    'LLY': 'Eli Lilly',
    'ABBV': 'AbbVie',
    'MRK': 'Merck',
    'PEP': 'PepsiCo',
    'AVGO': 'Broadcom',
    'COST': 'Costco',
    'ORCL': 'Oracle',
    'ADBE': 'Adobe',
    'CRM': 'Salesforce',
    'CSCO': 'Cisco',
    'ACN': 'Accenture',
    'WFC': 'Wells Fargo',
    'PM': 'Philip Morris',
    'COP': 'ConocoPhillips',
    'QCOM': 'Qualcomm',
    'BA': 'Boeing',
    'IBM': 'IBM',
    'CAT': 'Caterpillar',
    'GE': 'General Electric',
    'F': 'Ford',
    'GM': 'General Motors',
    'MMM': '3M',
    'T': 'AT&T',
    'VZ': 'Verizon',
  };

  Future<List<Map<String, dynamic>>> fetchStockMarkets() async {
    try {
      final List<Map<String, dynamic>> results = [];

      await Future.wait(
        top50Stocks.map((symbol) async {
          try {
            final url = Uri.parse(
              '$baseUrl/quote?symbol=$symbol&token=$apiKey',
            );
            final response = await http
                .get(url)
                .timeout(const Duration(seconds: 10));

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              final isValidC =
                  data is Map<String, dynamic> &&
                  data['c'] is num &&
                  (data['c'] as num) > 0;

              if (isValidC) {
                results.add({
                  'symbol': symbol,
                  'name': _stockNames[symbol] ?? symbol,
                  'current_price': (data['c'] as num).toDouble(),
                  'price_change_percentage_24h':
                      (data['dp'] as num?)?.toDouble() ?? 0.0,
                });
              }
            } else if (response.statusCode == 401 ||
                response.statusCode == 403) {
              // Silently fail
            }
          } catch (e) {
            // Silently fail
          }
        }),
      );

      if (results.isEmpty) throw Exception('Gagal fetch semua saham');

      results.sort((a, b) => b['current_price'].compareTo(a['current_price']));
      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
    double currentPrice,
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
        'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?range=$range&interval=$interval',
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
