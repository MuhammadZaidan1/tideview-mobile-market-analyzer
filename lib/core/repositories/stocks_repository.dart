import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../env/env.dart'; 

class StocksRepository {
  final String baseUrl = 'https://finnhub.io/api/v1';
  final String apiKey = Env.finnhubApiKey;
  final List<String> top15Stocks = [
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
  ];
  final Map<String, String> _stockNames = {
    'AAPL': 'Apple',
    'MSFT': 'Microsoft',
    'NVDA': 'NVIDIA',
    'GOOGL': 'Alphabet (Google)',
    'AMZN': 'Amazon',
    'META': 'Meta Platforms',
    'TSLA': 'Tesla',
    'NFLX': 'Netflix',
    'SBUX': 'Starbucks',
    'MCD': 'McDonald\'s',
    'NKE': 'Nike',
    'KO': 'Coca-Cola',
    'DIS': 'Walt Disney',
    'INTC': 'Intel',
    'AMD': 'AMD',
  };
  Future<List<Map<String, dynamic>>> fetchStockMarkets() async {
    try {
      final futures = top15Stocks.map((symbol) async {
        final url = Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return {
            'symbol': symbol,
            'name': _stockNames[symbol] ?? symbol,
            'current_price': (data['c'] as num?)?.toDouble() ?? 0.0,
            'price_change_percentage_24h':
                (data['dp'] as num?)?.toDouble() ?? 0.0,
          };
        }
        return <String, dynamic>{}; // Return kosong kalau 1 saham gagal
      });
      final results = await Future.wait(futures);
      return results.where((item) => item.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Error API Stocks Finnhub: $e');
    }
  }
  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    try {
      final to = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      int from;
      String resolution;
      switch (timeframe) {
        case '1D':
          from = to - (24 * 3600);
          resolution = '15';
          break;
        case '1W':
          from = to - (7 * 24 * 3600);
          resolution = '60';
          break;
        case '1M':
          from = to - (30 * 24 * 3600);
          resolution = 'D';
          break;
        case '3M':
          from = to - (90 * 24 * 3600);
          resolution = 'D';
          break;
        case '1Y':
          from = to - (365 * 24 * 3600);
          resolution = 'W';
          break;
        case 'ALL':
        default:
          from = to - (5 * 365 * 24 * 3600);
          resolution = 'M';
          break;
      }
      final url = Uri.parse(
        '$baseUrl/stock/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['s'] == 'ok') {
          final List<dynamic> timestamps = data['t'];
          final List<dynamic> prices = data['c'];
          final List<List<double>> formatted = [];
          for (int i = 0; i < timestamps.length; i++) {
            formatted.add([
              (timestamps[i] as num).toDouble() * 1000,
              (prices[i] as num).toDouble(),
            ]);
          }
          return formatted;
        }
      }
    } catch (e) {}
    return _generateDummyChart(100.0, timeframe);
  }

  List<List<double>> _generateDummyChart(
    double currentPrice,
    String timeframe,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch;
    int limit = 24;
    int intervalMs = 3600000;
    switch (timeframe) {
      case '1D':
        limit = 96;
        intervalMs = 15 * 60000;
        break;
      case '1W':
        limit = 84;
        intervalMs = 2 * 3600000;
        break;
      case '1M':
        limit = 120;
        intervalMs = 6 * 3600000;
        break;
      case '3M':
        limit = 90;
        intervalMs = 24 * 3600000;
        break;
      case '1Y':
        limit = 52;
        intervalMs = 7 * 86400000;
        break;
      case 'ALL':
        limit = 60;
        intervalMs = 30 * 86400000;
        break;
    }
    final startTime = now - (limit * intervalMs);
    double simulatedPrice = currentPrice > 0 ? currentPrice : 100.0;
    final random = Random();
    List<List<double>> reversedPoints = [];
    for (int i = limit; i >= 0; i--) {
      reversedPoints.add([
        (startTime + (i * intervalMs)).toDouble(),
        simulatedPrice,
      ]);
      double change = simulatedPrice * (random.nextDouble() * 0.008);
      simulatedPrice = random.nextBool()
          ? simulatedPrice - change
          : simulatedPrice + change;
    }
    return reversedPoints.reversed.toList();
  }
}
