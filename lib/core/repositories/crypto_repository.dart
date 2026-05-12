import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../database/chart_cache.dart';

class CryptoRepository {
  final String binanceUrl = 'https://data-api.binance.vision/api/v3';
  Future<List<Map<String, dynamic>>> fetchCryptoMarkets() async {
    try {
      final url = Uri.parse('$binanceUrl/ticker/24hr');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        var usdtPairs = rawData
            .where((coin) => coin['symbol'].toString().endsWith('USDT'))
            .toList();
        usdtPairs.sort((a, b) {
          final volA = double.parse(a['quoteVolume'].toString());
          final volB = double.parse(b['quoteVolume'].toString());
          return volB.compareTo(volA);
        });
        final top50 = usdtPairs.take(50).toList();
        return top50.map((coin) {
          final rawSymbol = coin['symbol'].toString();
          final cleanSymbol = rawSymbol.replaceAll('USDT', '');
          return {
            'symbol': cleanSymbol,
            'name': _getFriendlyName(cleanSymbol),
            'current_price': double.parse(coin['lastPrice'].toString()),
            'price_change_percentage_24h': double.parse(
              coin['priceChangePercent'].toString(),
            ),
          };
        }).toList();
      } else {
        throw Exception(
          'Gagal narik data dari Binance: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error API Binance Market: $e');
    }
  }

  String _getFriendlyName(String symbol) {
    const names = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'USDT': 'Tether',
      'BNB': 'BNB',
      'SOL': 'Solana',
      'USDC': 'USDC',
      'XRP': 'Ripple',
      'ADA': 'Cardano',
      'AVAX': 'Avalanche',
      'DOGE': 'Dogecoin',
      'DOT': 'Polkadot',
      'TRX': 'TRON',
      'LINK': 'Chainlink',
      'MATIC': 'Polygon',
      'POL': 'Polygon (POL)',
      'SHIB': 'Shiba Inu',
      'LTC': 'Litecoin',
      'BCH': 'Bitcoin Cash',
      'PEPE': 'Pepe',
      'NEAR': 'NEAR Protocol',
      'APT': 'Aptos',
      'ARB': 'Arbitrum',
      'OP': 'Optimism',
      'SUI': 'Sui',
      'INJ': 'Injective',
      'FDUSD': 'First Digital USD',
      'WIF': 'dogwifhat',
      'FLOKI': 'Floki',
      'GALA': 'Gala',
      'UNI': 'Uniswap',
      'ATOM': 'Cosmos',
      'XMR': 'Monero',
      'ETC': 'Ethereum Classic',
      'TON': 'Toncoin',
      'XLM': 'Stellar',
      'ICP': 'Internet Computer',
      'FIL': 'Filecoin',
      'HBAR': 'Hedera',
      'VET': 'VeChain',
      'MNT': 'Mantle',
      'MKR': 'Maker',
      'SAND': 'The Sandbox',
      'GRT': 'The Graph',
      'RNDR': 'Render',
      'ALGO': 'Algorand',
      'AAVE': 'Aave',
      'MANA': 'Decentraland',
      'THETA': 'Theta Network',
      'STX': 'Stacks',
      'EGLD': 'MultiversX',
      'AXS': 'Axie Infinity',
    };
    return names[symbol] ?? symbol;
  }

  List<List<double>> _generateStablecoinChart(String timeframe) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final formattedPrices = <List<double>>[];
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
    for (int i = 0; i <= limit; i++) {
      double dummyPrice = 1.0 + (i % 2 == 0 ? 0.0001 : -0.0001);
      formattedPrices.add([
        (startTime + (i * intervalMs)).toDouble(),
        dummyPrice,
      ]);
    }
    return formattedPrices;
  }

  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    final isar = Isar.getInstance();
    final upperSymbol = symbol.toUpperCase();
    final cacheKey = '${upperSymbol}_$timeframe';
    if (['USDT', 'USDC', 'DAI', 'FDUSD'].contains(upperSymbol)) {
      return _generateStablecoinChart(timeframe);
    }
    if (isar != null) {
      final cachedChart = await isar.chartCaches
          .where()
          .cacheKeyEqualTo(cacheKey)
          .findFirst();
      if (cachedChart != null &&
          DateTime.now().difference(cachedChart.lastUpdated).inMinutes < 30) {
        final List<dynamic> decoded = json.decode(cachedChart.pricesJson);
        return decoded
            .map(
              (e) => (e as List).cast<num>().map((n) => n.toDouble()).toList(),
            )
            .toList();
      }
    }
    final binanceSymbol = '${upperSymbol}USDT';
    String interval = '1h';
    int limit = 24;
    switch (timeframe) {
      case '1D':
        interval = '15m';
        limit = 96;
        break;
      case '1W':
        interval = '2h';
        limit = 84;
        break;
      case '1M':
        interval = '6h';
        limit = 120;
        break;
      case '3M':
        interval = '1d';
        limit = 90;
        break;
      case '1Y':
        interval = '1w';
        limit = 52;
        break;
      case 'ALL':
        interval = '1M';
        limit = 60;
        break;
    }
    try {
      final url = Uri.parse(
        '$binanceUrl/klines?symbol=$binanceSymbol&interval=$interval&limit=$limit',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> klines = json.decode(response.body);
        final List<List<double>> formattedPrices = [];
        for (var kline in klines) {
          formattedPrices.add([
            (kline[0] as num).toDouble(),
            double.parse(kline[4].toString()),
          ]);
        }
        if (isar != null) {
          final newCache = ChartCache()
            ..cacheKey = cacheKey
            ..pricesJson = json.encode(formattedPrices)
            ..lastUpdated = DateTime.now();
          await isar.writeTxn(() async {
            await isar.chartCaches.put(newCache);
          });
        }
        return formattedPrices;
      } else if (response.statusCode == 400) {
        throw Exception('Koin $symbol tidak tersedia.');
      } else {
        throw Exception('Gagal narik grafik Binance.');
      }
    } catch (e) {
      throw Exception('Error API Historical Data: $e');
    }
  }
}
