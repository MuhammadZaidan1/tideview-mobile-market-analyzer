import 'package:isar/isar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tideview/core/database/price_alert.dart';
import 'package:tideview/core/services/notification_helper.dart';
import '../database/asset_cache.dart';
import '../database/user_prefs.dart';
import '../repositories/crypto_repository.dart';
import '../repositories/forex_repository.dart';
import '../repositories/stocks_repository.dart';
import '../services/isar_service.dart';

class MarketSyncUseCase {
  final CryptoRepository apiRepo;
  final IsarService isarService;
  final ForexRepository forexRepo = ForexRepository();
  final StocksRepository stocksRepo = StocksRepository();
  MarketSyncUseCase({required this.apiRepo, required this.isarService});
  Future<Map<String, dynamic>> getCryptoData() async {
    final isar = await isarService.db;
    try {
      final prefs = await isar.userPrefs.get(1);
      final lastSync = prefs?.lastCryptoSyncTime;
      final now = DateTime.now();
      final cachedData = await isar.assetCaches.where().findAll();
      if (lastSync != null &&
          now.difference(lastSync).inMinutes < 3 &&
          cachedData.isNotEmpty) {
        return {'isOffline': false, 'data': cachedData};
      }
      final results = await Future.wait([
        apiRepo.fetchCryptoMarkets().catchError((e) {
          return <Map<String, dynamic>>[];
        }),
        forexRepo.fetchForexMarkets().catchError((e) {
          return <Map<String, dynamic>>[];
        }),
        stocksRepo.fetchStockMarkets().catchError((e) {
          return <Map<String, dynamic>>[];
        }),
      ]);
      final List<AssetCache> masterCache = [];
      double btcPrice = 0.0;
      void processAssets(
        List<Map<String, dynamic>> apiList,
        String marketType,
      ) {
        for (final item in apiList) {
          final sym = item['symbol']?.toString().toUpperCase() ?? '';
          final existing = cachedData.where((c) => c.symbol == sym).firstOrNull;
          final cache = AssetCache()
            ..symbol = sym
            ..name = item['name']?.toString() ?? sym
            ..currentPrice = item['current_price']?.toDouble() ?? 0.0
            ..priceChange24h =
                item['price_change_percentage_24h']?.toDouble() ?? 0.0
            ..lastUpdated = DateTime.now()
            ..marketType = marketType
            ..isWatchlisted = existing?.isWatchlisted ?? false
            ..customCategories = existing?.customCategories ?? []
            ..sortOrder = existing?.sortOrder ?? 0;
          masterCache.add(cache);
          if (cache.symbol == 'BTC') btcPrice = cache.currentPrice;
        }
      }
      processAssets(results[0], 'crypto');
      processAssets(results[1], 'forex');
      processAssets(results[2], 'stocks');
      if (masterCache.isEmpty) {
        return {'isOffline': true, 'data': cachedData};
      }
      await isar.writeTxn(() async {
        await isar.assetCaches.putAll(masterCache);
        if (prefs != null) {
          prefs.lastCryptoSyncTime = DateTime.now();
          await isar.userPrefs.put(prefs);
        }
        final activeAlerts = await isar.priceAlerts
            .filter()
            .isActiveEqualTo(true)
            .findAll();
        for (var alert in activeAlerts) {
          final asset = masterCache
              .where((a) => a.symbol == alert.symbol)
              .firstOrNull;
          if (asset != null) {
            bool isTriggered = false;
            if (alert.isAbove && asset.currentPrice >= alert.targetPrice) {
              isTriggered = true;
            } else if (!alert.isAbove &&
                asset.currentPrice <= alert.targetPrice) {
              isTriggered = true;
            }
            if (isTriggered) {
              await NotificationHelper.showPriceAlertNotification(
                alert.symbol,
                alert.targetPrice,
                asset.currentPrice,
                alert.isAbove,
              );
              alert.isActive = false;
              await isar.priceAlerts.put(alert);
            }
          }
        }
      });
      if (btcPrice > 0) {
        await HomeWidget.saveWidgetData<String>(
          'btc_price_widget',
          '\$${btcPrice.toStringAsFixed(2)}',
        );
        await HomeWidget.updateWidget(
          name: 'TideWidgetProvider',
          androidName: 'TideWidgetProvider',
        );
      }
      return {'isOffline': false, 'data': masterCache};
    } catch (e) {
      final cachedData = await isar.assetCaches.where().findAll();
      return {'isOffline': true, 'data': cachedData};
    }
  }
}
