import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../database/schemas.dart';
import '../database/asset_cache.dart';
import '../database/user_prefs.dart';
import '../database/price_alert.dart';
import '../database/watchlist_category.dart';
import 'supabase_service.dart';

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
        await _syncWatchlistToCloud(asset);
      }
    } on IsarError {}
  }

  /// Push status watchlist 1 asset ke Supabase (cuma kalau user login).
  /// Silently fail -- kegagalan sync gak boleh ganggu pengalaman lokal.
  Future<void> _syncWatchlistToCloud(AssetCache asset) async {
    if (!isLoggedIn) return;
    try {
      await supabase.from('user_watchlist').upsert({
        'user_id': currentUser!.id,
        'symbol': asset.symbol,
        'is_watchlisted': asset.isWatchlisted,
        'custom_categories': asset.customCategories,
        'sort_order': asset.sortOrder,
      }, onConflict: 'user_id,symbol');
    } catch (_) {}
  }

  Future<void> savePriceAlert(PriceAlert alert) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.priceAlerts.put(alert);
      });
      await _syncAlertToCloud(alert);
    } on IsarError {}
  }

  Future<void> _syncAlertToCloud(PriceAlert alert) async {
    if (!isLoggedIn) return;
    try {
      await supabase.from('price_alerts').upsert({
        'user_id': currentUser!.id,
        'symbol': alert.symbol,
        'target_price': alert.targetPrice,
        'is_above': alert.isAbove,
        'is_active': alert.isActive,
      }, onConflict: 'user_id,symbol,target_price,is_above');
    } catch (_) {}
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
      if (isLoggedIn) {
        try {
          await supabase.from('watchlist_categories').upsert({
            'user_id': currentUser!.id,
            'name': category.name,
            'sort_order': category.sortOrder,
          }, onConflict: 'user_id,name');
        } catch (_) {}
      }
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
      if (isLoggedIn) {
        try {
          await supabase
              .from('watchlist_categories')
              .delete()
              .eq('user_id', currentUser!.id)
              .eq('name', name);
        } catch (_) {}
      }
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
        await _syncWatchlistToCloud(asset);
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
      if (isLoggedIn) {
        try {
          for (final cat in categories) {
            await supabase.from('watchlist_categories').upsert({
              'user_id': currentUser!.id,
              'name': cat.name,
              'sort_order': cat.sortOrder,
            }, onConflict: 'user_id,name');
          }
        } catch (_) {}
      }
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
      final alert = await isar.priceAlerts.get(id);
      await isar.writeTxn(() async {
        await isar.priceAlerts.delete(id);
      });
      if (alert != null && isLoggedIn) {
        try {
          await supabase
              .from('price_alerts')
              .delete()
              .eq('user_id', currentUser!.id)
              .eq('symbol', alert.symbol)
              .eq('target_price', alert.targetPrice)
              .eq('is_above', alert.isAbove);
        } catch (_) {}
      }
    } on IsarError {}
  }

  /// Ambil watchlist dari Supabase, gabung ke Isar lokal. Aman dipanggil
  /// berkali-kali (idempotent) -- dipakai sebagai "self-healing pass" buat
  /// ngalahin race condition sama market sync (lihat catatan di
  /// syncCloudDataOnLogin).
  Future<void> _pullWatchlistFromCloud(String userId) async {
    try {
      final isar = await db;
      final remoteWatchlist = await supabase
          .from('user_watchlist')
          .select()
          .eq('user_id', userId);

      // Ambil detail asset (name/price/marketType) langsung dari table
      // `assets` (publik, gak butuh login) -- JANGAN cuma andelin assetCaches
      // lokal, karena pas abis clear data / login pertama kali di device baru,
      // assetCaches lokal masih kosong (market sync lokal belum sempat jalan).
      final remoteSymbols = remoteWatchlist
          .map((r) => r['symbol']?.toString())
          .whereType<String>()
          .toList();

      final Map<String, Map<String, dynamic>> assetDetailsBySymbol = {};
      if (remoteSymbols.isNotEmpty) {
        final assetDetails = await supabase
            .from('assets')
            .select()
            .inFilter('symbol', remoteSymbols);
        for (final row in assetDetails) {
          final sym = row['symbol']?.toString();
          if (sym != null) assetDetailsBySymbol[sym] = row;
        }
      }

      await isar.writeTxn(() async {
        for (final row in remoteWatchlist) {
          final symbol = row['symbol']?.toString();
          if (symbol == null) continue;

          var asset = await isar.assetCaches
              .filter()
              .symbolEqualTo(symbol)
              .findFirst();

          // Kalau belum ada lokal, bikin baru pakai detail dari table
          // `assets` (harga sebenarnya bakal ke-update lagi begitu market
          // sync jalan -- yang penting flag watchlist-nya gak ilang).
          if (asset == null) {
            final detail = assetDetailsBySymbol[symbol];
            asset = AssetCache()
              ..symbol = symbol
              ..name = detail?['name']?.toString() ?? symbol
              ..currentPrice =
                  (detail?['current_price'] as num?)?.toDouble() ?? 0.0
              ..priceChange24h =
                  (detail?['price_change_24h'] as num?)?.toDouble() ?? 0.0
              ..marketType = detail?['market_type']?.toString() ?? 'crypto'
              ..lastUpdated = DateTime.now();
          }

          asset.isWatchlisted = row['is_watchlisted'] == true;
          final cats = row['custom_categories'];
          if (cats is List) {
            asset.customCategories = cats.map((e) => e.toString()).toList();
          }
          if (row['sort_order'] != null) {
            asset.sortOrder = row['sort_order'] as int;
          }
          await isar.assetCaches.put(asset);
        }
      });
    } catch (_) {
      // Silently fail
    }
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
        await _syncAlertToCloud(alert);
      }
    } on IsarError {}
  }

  /// Dipanggil sekali tiap kali ada event login (baru login atau resume
  /// sesi). Push data lokal (misal dari sesi guest) ke akun, lalu pull data
  /// yang udah ada di akun (misal dari device lain) dan gabung ke Isar lokal.
  /// Silently fail total -- app harus tetap jalan normal walau sync gagal
  /// (misal lagi offline pas login).
  Future<void> syncCloudDataOnLogin() async {
    if (!isLoggedIn) return;
    final userId = currentUser!.id;

    try {
      final isar = await db;

      // 1. PUSH -- kirim watchlist/kategori/alert lokal (misal dari sesi
      //    guest sebelum login) ke akun, biar gak hilang.
      final localWatchlisted = await isar.assetCaches
          .filter()
          .isWatchlistedEqualTo(true)
          .findAll();
      for (final asset in localWatchlisted) {
        await _syncWatchlistToCloud(asset);
      }

      final localCategories = await isar.watchlistCategorys.where().findAll();
      for (final cat in localCategories) {
        try {
          await supabase.from('watchlist_categories').upsert({
            'user_id': userId,
            'name': cat.name,
            'sort_order': cat.sortOrder,
          }, onConflict: 'user_id,name');
        } catch (_) {}
      }

      final localActiveAlerts = await isar.priceAlerts
          .filter()
          .isActiveEqualTo(true)
          .findAll();
      for (final alert in localActiveAlerts) {
        await _syncAlertToCloud(alert);
      }

      // 2. PULL -- ambil data yang udah ada di akun (misal login pertama
      //    kali di device ini, tapi udah ada history dari device lain),
      //    gabung ke Isar lokal.
      //
      // Dipanggil BERKALI-KALI dalam window 15 detik pertama (bukan cuma
      // sekali). Kenapa: market sync biasa (dari Dashboard yang lagi
      // mounting) JUGA nulis ke assetCaches di waktu yang bersamaan, dan ada
      // cooldown 45 detik di kode lama yang bikin salah satu tulisan
      // ke-skip diam-diam tergantung siapa yang nulis duluan (race
      // condition dari kode asli, baru ketauan sekarang). Reapply berkali-
      // kali ini ningkatin peluang tulisan KITA yang jadi "yang terakhir
      // menang", tanpa perlu restrukturisasi besar ke market_sync_usecase.
      await _pullWatchlistFromCloud(userId);
      for (final delaySeconds in [2, 4, 7, 11, 15]) {
        Future.delayed(Duration(seconds: delaySeconds), () {
          _pullWatchlistFromCloud(userId);
        });
      }

      final remoteCategories = await supabase
          .from('watchlist_categories')
          .select()
          .eq('user_id', userId);

      await isar.writeTxn(() async {
        for (final row in remoteCategories) {
          final name = row['name']?.toString();
          if (name == null) continue;
          final existing = await isar.watchlistCategorys
              .filter()
              .nameEqualTo(name)
              .findFirst();
          final cat = existing ?? WatchlistCategory();
          cat.name = name;
          if (row['sort_order'] != null) {
            cat.sortOrder = row['sort_order'] as int;
          }
          await isar.watchlistCategorys.put(cat);
        }
      });

      final remoteAlerts = await supabase
          .from('price_alerts')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      await isar.writeTxn(() async {
        for (final row in remoteAlerts) {
          final symbol = row['symbol']?.toString();
          final targetPrice = (row['target_price'] as num?)?.toDouble();
          final isAbove = row['is_above'] as bool?;
          if (symbol == null || targetPrice == null || isAbove == null) {
            continue;
          }
          final existing = await isar.priceAlerts
              .filter()
              .symbolEqualTo(symbol)
              .and()
              .targetPriceEqualTo(targetPrice)
              .and()
              .isAboveEqualTo(isAbove)
              .findFirst();
          if (existing == null) {
            final newAlert = PriceAlert()
              ..symbol = symbol
              ..targetPrice = targetPrice
              ..isAbove = isAbove
              ..isActive = true;
            await isar.priceAlerts.put(newAlert);
          }
        }
      });
    } catch (_) {
      // Silently fail -- sync gagal gak boleh block user pakai app
    }
  }
}
