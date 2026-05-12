import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

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
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];
        final random = Random();
        return rates.entries.map((e) {
          final symbol = e.key;
          final price = (e.value as num).toDouble();
          final dummyChange = (random.nextDouble() * 2.4) - 1.2;
          return {
            'symbol': symbol,
            'name': _currencyNames[symbol] ?? '$symbol Currency',
            'current_price': 1 / price, // Inverse biar base USD
            'price_change_percentage_24h': dummyChange,
          };
        }).toList();
      } else {
        throw Exception('Gagal narik data Frankfurter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error API Forex: $e');
    }
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
    double simulatedPrice = currentPrice > 0 ? currentPrice : 1.0;
    final random = Random();
    List<List<double>> reversedPoints = [];
    for (int i = limit; i >= 0; i--) {
      reversedPoints.add([
        (startTime + (i * intervalMs)).toDouble(),
        simulatedPrice,
      ]);
      double change = simulatedPrice * (random.nextDouble() * 0.003);
      simulatedPrice = random.nextBool()
          ? simulatedPrice - change
          : simulatedPrice + change;
    }
    return reversedPoints.reversed.toList();
  }
  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    return _generateDummyChart(1.0, timeframe);
  }
}
