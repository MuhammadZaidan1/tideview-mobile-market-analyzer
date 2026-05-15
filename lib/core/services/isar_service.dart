import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../database/schemas.dart';
import '../database/asset_cache.dart';
import '../database/user_prefs.dart';
import '../database/price_alert.dart';
import '../database/watchlist_category.dart';

class IsarService {
  static IsarService? _instance;

  late Future<Isar> db;

  IsarService._internal() {
    db = openDB();
  }

  factory IsarService() {
    _instance ??= IsarService._internal();
    return _instance!;
  }

  Future<Isar> openDB() async {
    try {
      if (Isar.instanceNames.isEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        return await Isar.open(appSchemas, directory: dir.path);
      }
      final instance = Isar.getInstance();
      if (instance == null) {
        final dir = await getApplicationDocumentsDirectory();
        return await Isar.open(appSchemas, directory: dir.path);
      }
      return Future.value(instance);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> saveUserPrefs(UserPrefs prefs) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.userPrefs.put(prefs);
      });
    } on IsarError {}
  }

  Future<UserPrefs?> getUserPrefs() async {
    try {
      final isar = await db;
      return await isar.userPrefs.get(1);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleWatchlist(String symbol) async {
    try {
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
    } on IsarError {}
  }

  Future<void> savePriceAlert(PriceAlert alert) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.priceAlerts.put(alert);
      });
    } on IsarError {}
  }

  Future<void> createCustomCategory(String name) async {
    try {
      final isar = await db;
      final count = await isar.watchlistCategorys.count();
      final category = WatchlistCategory()
        ..name = name
        ..sortOrder = count;
      await isar.writeTxn(() async {
        await isar.watchlistCategorys.put(category);
      });
    } on IsarError {}
  }

  Future<void> deleteCustomCategory(String name) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.watchlistCategorys.filter().nameEqualTo(name).deleteAll();
        final assets = await isar.assetCaches
            .filter()
            .customCategoriesElementEqualTo(name)
            .findAll();
        final updatedAssets = <AssetCache>[];
        for (var asset in assets) {
          final updatedList = List<String>.from(asset.customCategories)
            ..remove(name);
          asset.customCategories = updatedList;
          updatedAssets.add(asset);
        }
        if (updatedAssets.isNotEmpty) {
          await isar.assetCaches.putAll(updatedAssets);
        }
      });
    } on IsarError {}
  }

  Future<void> toggleAssetCustomCategory(
    String symbol,
    String categoryName,
  ) async {
    try {
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
    } on IsarError {}
  }

  Future<void> updateCategorySortOrders(
    List<WatchlistCategory> categories,
  ) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        for (int i = 0; i < categories.length; i++) {
          categories[i].sortOrder = i;
        }
        await isar.watchlistCategorys.putAll(categories);
      });
    } on IsarError {}
  }

  Future<List<PriceAlert>> getAllPriceAlerts() async {
    try {
      final isar = await db;
      return await isar.priceAlerts.where().findAll();
    } catch (_) {
      return [];
    }
  }

  Future<void> deletePriceAlert(int id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.priceAlerts.delete(id);
      });
    } on IsarError {}
  }

  Future<void> togglePriceAlert(int id) async {
    try {
      final isar = await db;
      final alert = await isar.priceAlerts.get(id);
      if (alert != null) {
        alert.isActive = !alert.isActive;
        await isar.writeTxn(() async {
          await isar.priceAlerts.put(alert);
        });
      }
    } on IsarError {}
  }
}
