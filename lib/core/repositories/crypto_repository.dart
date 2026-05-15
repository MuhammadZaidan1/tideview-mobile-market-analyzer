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
        final List<dynamic>? rawData =
            json.decode(response.body) as List<dynamic>?;

        if (rawData == null || rawData.isEmpty) {
          throw ArgumentError('Data dari Binance kosong atau null');
        }

        var usdtPairs = rawData.whereType<Map<String, dynamic>>().where((coin) {
          final symbol = coin['symbol']?.toString() ?? '';
          return symbol.isNotEmpty && symbol.endsWith('USDT');
        }).toList();

        if (usdtPairs.isEmpty) {
          throw Exception('Tidak ada pair USDT yang ditemukan');
        }

        usdtPairs.sort((a, b) {
          try {
            final volA =
                double.tryParse(a['quoteVolume']?.toString() ?? '0') ?? 0.0;
            final volB =
                double.tryParse(b['quoteVolume']?.toString() ?? '0') ?? 0.0;
            return volB.compareTo(volA);
          } catch (e) {
            return 0;
          }
        });

        final top50 = usdtPairs.take(50).toList();

        return top50.map((coin) {
          final rawSymbol = coin['symbol']?.toString() ?? '';
          final cleanSymbol = rawSymbol.replaceAll('USDT', '');
          return {
            'symbol': cleanSymbol,
            'name': _getFriendlyName(cleanSymbol),
            'current_price':
                double.tryParse(coin['lastPrice']?.toString() ?? '0') ?? 0.0,
            'price_change_percentage_24h':
                double.tryParse(
                  coin['priceChangePercent']?.toString() ?? '0',
                ) ??
                0.0,
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

  Future<List<List<double>>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    final isar = Isar.getInstance();
    final upperSymbol = symbol.toUpperCase();
    final cacheKey = '${upperSymbol}_$timeframe';
    if (['USDT', 'USDC', 'DAI', 'FDUSD'].contains(upperSymbol)) {
      return []; 
    }

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
