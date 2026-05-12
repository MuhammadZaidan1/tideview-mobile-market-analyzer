import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../database/schemas.dart';
import '../database/asset_cache.dart';
import '../database/user_prefs.dart';
import '../database/price_alert.dart';
import '../database/watchlist_category.dart';

class IsarService {
  late Future<Isar> db;
  IsarService() {
    db = openDB();
  }
  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(appSchemas, directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }
  Future<void> saveUserPrefs(UserPrefs prefs) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.userPrefs.put(prefs);
    });
  }
  Future<UserPrefs?> getUserPrefs() async {
    final isar = await db;
    return await isar.userPrefs.get(1);
  }
  Future<void> toggleWatchlist(String symbol) async {
    final isar = await db;
    final asset = await isar.assetCaches
        .filter()
        .symbolEqualTo(symbol)
        .findFirst();
    if (asset != null) {
      asset.isWatchlisted = !asset.isWatchlisted;
      await isar.writeTxn(() async {
        await isar.assetCaches.put(asset);
      });
    }
  }
  Future<void> savePriceAlert(PriceAlert alert) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.priceAlerts.put(alert);
    });
  }
  Future<void> createCustomCategory(String name) async {
    final isar = await db;
    final count = await isar.watchlistCategorys.count();
    final category = WatchlistCategory()
      ..name = name
      ..sortOrder = count;
    await isar.writeTxn(() async {
      await isar.watchlistCategorys.put(category);
    });
  }
  Future<void> deleteCustomCategory(String name) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.watchlistCategorys.filter().nameEqualTo(name).deleteAll();
      final assets = await isar.assetCaches
          .filter()
          .customCategoriesElementEqualTo(name)
          .findAll();
      for (var asset in assets) {
        final updatedList = List<String>.from(asset.customCategories)
          ..remove(name);
        asset.customCategories = updatedList;
        await isar.assetCaches.put(asset);
      }
    });
  }
  Future<void> toggleAssetCustomCategory(
    String symbol,
    String categoryName,
  ) async {
    final isar = await db;
    final asset = await isar.assetCaches
        .filter()
        .symbolEqualTo(symbol)
        .findFirst();
    if (asset != null) {
      final currentList = List<String>.from(asset.customCategories);
      if (currentList.contains(categoryName)) {
        currentList.remove(categoryName);
      } else {
        currentList.add(categoryName);
        asset.isWatchlisted = true;
      }
      asset.customCategories = currentList;
      await isar.writeTxn(() async {
        await isar.assetCaches.put(asset);
      });
    }
  }
  Future<void> updateCategorySortOrders(
    List<WatchlistCategory> categories,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      for (int i = 0; i < categories.length; i++) {
        categories[i].sortOrder = i;
        await isar.watchlistCategorys.put(categories[i]);
      }
    });
  }
  Future<List<PriceAlert>> getAllPriceAlerts() async {
    final isar = await db;
    return await isar.priceAlerts.where().findAll();
  }
  Future<void> deletePriceAlert(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.priceAlerts.delete(id);
    });
  }
  Future<void> togglePriceAlert(int id) async {
    final isar = await db;
    final alert = await isar.priceAlerts.get(id);
    if (alert != null) {
      alert.isActive = !alert.isActive;
      await isar.writeTxn(() async {
        await isar.priceAlerts.put(alert);
      });
    }
  }
}
