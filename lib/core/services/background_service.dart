import 'package:tideview/shared/utils/currency_formatter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tideview/core/database/price_alert.dart';
import 'package:tideview/core/services/notification_helper.dart';
import '../database/schemas.dart';
import '../database/asset_cache.dart';
import '../database/user_prefs.dart';
import '../repositories/crypto_repository.dart';
import '../repositories/forex_repository.dart';
import '../repositories/stocks_repository.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final isar =
          Isar.getInstance() ??
          await Isar.open(appSchemas, directory: dir.path);
      final cachedData = await isar.assetCaches.where().findAll();
      final prefs = await isar.userPrefs.get(1);
      final targetSymbol = prefs?.widgetAssetSymbol ?? 'BTC';
      final results = await Future.wait([
        CryptoRepository().fetchCryptoMarkets().catchError(
          (_) => <Map<String, dynamic>>[],
        ),
        ForexRepository().fetchForexMarkets().catchError(
          (_) => <Map<String, dynamic>>[],
        ),
        StocksRepository().fetchStockMarkets().catchError(
          (_) => <Map<String, dynamic>>[],
        ),
      ]);
      final List<AssetCache> masterCache = [];
      void processAssets(
        List<Map<String, dynamic>> apiList,
        String marketType,
      ) {
        for (final item in apiList) {
          final sym = item['symbol']?.toString().toUpperCase() ?? '';
          final existing = cachedData.where((c) => c.symbol == sym).firstOrNull;
          masterCache.add(
            AssetCache()
              ..symbol = sym
              ..name = item['name']?.toString() ?? sym
              ..currentPrice = item['current_price']?.toDouble() ?? 0.0
              ..priceChange24h =
                  item['price_change_percentage_24h']?.toDouble() ?? 0.0
              ..lastUpdated = DateTime.now()
              ..marketType = marketType
              ..isWatchlisted = existing?.isWatchlisted ?? false
              ..customCategories = existing?.customCategories ?? []
              ..sortOrder = existing?.sortOrder ?? 0,
          );
        }
      }
      processAssets(results[0], 'crypto');
      processAssets(results[1], 'forex');
      processAssets(results[2], 'stocks');
      await isar.writeTxn(() async {
        await isar.assetCaches.putAllByIndex('symbol', masterCache);
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
      final targetAsset = await isar.assetCaches
          .filter()
          .symbolEqualTo(targetSymbol, caseSensitive: false)
          .findFirst();
      if (targetAsset != null) {
        final targetCurrency = prefs?.baseCurrency ?? 'USD';
        final exchangeRate = prefs?.exchangeRate ?? 1.0;
        final formattedPrice = CurrencyFormatter.format(
          targetAsset.currentPrice,
          targetCurrency,
          exchangeRate,
        );
        final formattedChange =
            '${targetAsset.priceChange24h >= 0 ? '+' : ''}${targetAsset.priceChange24h.toStringAsFixed(2)}%';
        await HomeWidget.saveWidgetData<String>(
          'widget_name',
          targetAsset.name,
        );
        await HomeWidget.saveWidgetData<String>(
          'widget_symbol',
          targetAsset.symbol,
        );
        await HomeWidget.saveWidgetData<String>('widget_price', formattedPrice);
        await HomeWidget.saveWidgetData<String>(
          'widget_change',
          formattedChange,
        );
        await HomeWidget.updateWidget(
          name: 'TideWidgetProvider',
          androidName: 'TideWidgetProvider',
        );
      }
      return Future.value(true);
    } catch (err) {
      return Future.value(false);
    }
  });
}
