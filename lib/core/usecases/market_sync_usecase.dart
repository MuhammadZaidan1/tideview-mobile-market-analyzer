import 'package:flutter/foundation.dart';
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

  Future<Map<String, dynamic>> getCryptoData({
    bool forceRefresh = false,
  }) async {
    final isar = await isarService.db;
    try {
      final prefs = await isar.userPrefs.get(1);
      final lastSync = prefs?.lastCryptoSyncTime;
      final now = DateTime.now();
      final cachedData = await isar.assetCaches.where().findAll();

      if (!forceRefresh &&
          lastSync != null &&
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

      // FIX: assets yang di-watchlist tapi udah gak masuk hasil fetch top-N
      // kali ini (misal coin jatuh dari top-50 CoinGecko) tetap di-carry-over
      // pakai data terakhir yang ke-cache, bukan didiemin ilang dari list.
      // Tanpa ini, watchlist bisa "kehilangan" item secara diam-diam kapan
      // pun rank-nya berubah -- gak ada hubungannya sama sync akun,
      // ini bug lama di logic masterCache yang baru ketauan sekarang.
      final masterCacheSymbols = masterCache.map((a) => a.symbol).toSet();
      for (final cached in cachedData) {
        if (cached.isWatchlisted &&
            !masterCacheSymbols.contains(cached.symbol)) {
          masterCache.add(cached);
        }
      }

      if (masterCache.isEmpty) {
        return {'isOffline': true, 'data': cachedData};
      }

      await isar.writeTxn(() async {
        final currentPrefs = await isar.userPrefs.get(1);
        final currentTime = DateTime.now();
        if (currentPrefs != null && currentPrefs.lastCryptoSyncTime != null) {
          final diff = currentTime.difference(currentPrefs.lastCryptoSyncTime!);
          if (diff.inSeconds < 45) {
            return;
          }
        }

        await isar.assetCaches.putAll(masterCache);
        if (currentPrefs != null) {
          currentPrefs.lastCryptoSyncTime = currentTime;
          await isar.userPrefs.put(currentPrefs);
        }

        final activeAlerts = await isar.priceAlerts
            .filter()
            .isActiveEqualTo(true)
            .findAll();

        final assetMap = <String, AssetCache>{};
        for (final asset in masterCache) {
          assetMap[asset.symbol] = asset;
        }

        final alertsToUpdate = <PriceAlert>[];

        for (var alert in activeAlerts) {
          final asset = assetMap[alert.symbol];

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
              alertsToUpdate.add(alert);
            }
          }
        }

        if (alertsToUpdate.isNotEmpty) {
          await isar.priceAlerts.putAll(alertsToUpdate);
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
      try {
        final fallbackData = await isar.assetCaches.where().findAll();
        return {'isOffline': true, 'data': fallbackData};
      } catch (cacheError) {
        return {'isOffline': true, 'data': const []};
      }
    }
  }
}
