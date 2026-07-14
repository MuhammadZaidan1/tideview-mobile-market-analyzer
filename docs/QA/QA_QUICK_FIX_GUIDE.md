# 🚀 TideView QA - Quick Fix Guide

## Critical Issues - Implement Immediately

### ISSUE #1: Fix CryptoRepository Null Checks

**File:** `lib/core/repositories/crypto_repository.dart`

**Quick Fix Snippet:**

```dart
// BEFORE (Line 16-27)
if (response.statusCode == 200) {
  final List<dynamic> rawData = json.decode(response.body);
  var usdtPairs = rawData
      .where((coin) => coin['symbol'].toString().endsWith('USDT'))
      .toList();

// AFTER
if (response.statusCode == 200) {
  final List<dynamic>? rawData = json.decode(response.body) as List<dynamic>?;

  if (rawData == null || rawData.isEmpty) {
    throw ArgumentError('Binance returned null or empty data');
  }

  var usdtPairs = rawData
      .whereType<Map<String, dynamic>>()
      .where((coin) {
        final symbol = coin['symbol']?.toString() ?? '';
        return symbol.isNotEmpty && symbol.endsWith('USDT');
      })
      .toList();
```

---

### ISSUE #2: Add Error Logging to background_service.dart

**File:** `lib/core/services/background_service.dart`

**Quick Fix:**

```dart
// BEFORE (Line 153-155)
} catch (err) {
  return Future.value(false);
}

// AFTER
} catch (err, stack) {
  debugPrint('🔥 Background sync failed: $err\n$stack');
  // Optionally add Crashlytics.instance.recordError(err, stack);
  return Future.value(false);
}
```

---

### ISSUE #3: Optimize Alert Lookup with Map (O(n) → O(1))

**File:** `lib/core/usecases/market_sync_usecase.dart` (Line 89-121)

**Quick Fix:**

```dart
// BEFORE (Line 99-107)
for (var alert in activeAlerts) {
  final asset = masterCache
      .where((a) => a.symbol == alert.symbol)
      .firstOrNull;

// AFTER
// Create symbol->asset map before loop
final assetMap = <String, AssetCache>{};
for (final asset in masterCache) {
  assetMap[asset.symbol] = asset;
}

// Now O(1) lookup
for (var alert in activeAlerts) {
  final asset = assetMap[alert.symbol];
```

---

### ISSUE #4: Fix ForexRepository Validation

**File:** `lib/core/repositories/forex_repository.dart` (Line 33-55)

**Quick Fix:**

```dart
// BEFORE
final data = json.decode(response.body);
final Map<String, dynamic> rates = data['rates'];
return rates.entries.map((e) {
  final price = (e.value as num).toDouble();
  return {
    'current_price': 1 / price,
    ...
  };
}).toList();

// AFTER
final decodedData = json.decode(response.body);
if (decodedData is! Map<String, dynamic>) {
  throw FormatException('Expected JSON object');
}

final rates = decodedData['rates'];
if (rates is! Map<String, dynamic> || rates.isEmpty) {
  throw ApiException('Invalid rates response');
}

final result = <Map<String, dynamic>>[];
for (final entry in rates.entries) {
  final rateValue = entry.value;
  if (rateValue is! num || rateValue <= 0) {
    debugPrint('⚠️ Invalid rate: ${entry.key} = $rateValue');
    continue;
  }

  result.add({
    'symbol': entry.key,
    'name': _currencyNames[entry.key] ?? '${entry.key} Currency',
    'current_price': 1 / (rateValue as num).toDouble(),
    ...
  });
}
return result;
```

---

### ISSUE #5: Fix Empty Catch in StocksRepository

**File:** `lib/core/repositories/stocks_repository.dart` (Line 136)

**Quick Fix:**

```dart
// BEFORE
} catch (e) {}
return _generateDummyChart(100.0, timeframe);

// AFTER
} on SocketException catch (e) {
  debugPrint('❌ Network error fetching $symbol: $e');
  return _generateDummyChart(100.0, timeframe);
} on TimeoutException catch (e) {
  debugPrint('❌ Timeout fetching $symbol: $e');
  return _generateDummyChart(100.0, timeframe);
} catch (e) {
  debugPrint('❌ Error fetching historical data for $symbol: $e');
  return _generateDummyChart(100.0, timeframe);
}
```

---

### ISSUE #6: Fix IsarService.openDB() Null Safety

**File:** `lib/core/services/isar_service.dart` (Line 11-20)

**Quick Fix:**

```dart
// BEFORE
Future<Isar> openDB() async {
  if (Isar.instanceNames.isEmpty) {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(appSchemas, directory: dir.path);
  }
  return Future.value(Isar.getInstance());
}

// AFTER
Future<Isar> openDB() async {
  final existing = Isar.getInstance();
  if (existing != null) {
    return existing;
  }

  final dir = await getApplicationDocumentsDirectory();
  try {
    return await Isar.open(appSchemas, directory: dir.path);
  } on IsarError catch (e) {
    throw Exception('Failed to open database: $e');
  }
}
```

---

### ISSUE #7: Protect writeTxn Calls

**File:** `lib/core/services/isar_service.dart` (Multiple locations)

**Quick Fix Template:**

```dart
// BEFORE
await isar.writeTxn(() async {
  await isar.userPrefs.put(prefs);
});

// AFTER
try {
  await isar.writeTxn(() async {
    await isar.userPrefs.put(prefs);
  });
} on IsarError catch (e) {
  debugPrint('❌ Database transaction failed: $e');
  rethrow;
}
```

**Apply to these methods:**

- `saveUserPrefs()` - Line 27
- `toggleWatchlist()` - Line 45
- `savePriceAlert()` - Line 53
- `createCustomCategory()` - Line 66
- `deleteCustomCategory()` - Line 73
- `toggleAssetCustomCategory()` - Line 110
- `updateCategorySortOrders()` - Line 121
- `deletePriceAlert()` - Line 140
- `togglePriceAlert()` - Line 150

---

### ISSUE #8: Optimize updateCategorySortOrders

**File:** `lib/core/services/isar_service.dart` (Line 107-116)

**Quick Fix:**

```dart
// BEFORE
Future<void> updateCategorySortOrders(List<WatchlistCategory> categories) async {
  final isar = await db;
  await isar.writeTxn(() async {
    for (int i = 0; i < categories.length; i++) {
      categories[i].sortOrder = i;
      await isar.watchlistCategorys.put(categories[i]);
    }
  });
}

// AFTER
Future<void> updateCategorySortOrders(List<WatchlistCategory> categories) async {
  final isar = await db;

  for (int i = 0; i < categories.length; i++) {
    categories[i].sortOrder = i;
  }

  try {
    await isar.writeTxn(() async {
      await isar.watchlistCategorys.putAll(categories);
    });
  } on IsarError catch (e) {
    debugPrint('❌ Failed to update sort orders: $e');
    rethrow;
  }
}
```

---

### ISSUE #9: Fix MarketSyncUseCase Error Handling

**File:** `lib/core/usecases/market_sync_usecase.dart` (Line 148+)

**Quick Fix:**

```dart
// BEFORE
} catch (e) {
  debugPrint('🔥 Fatal Sync Error di Usecase: $e');
  final cachedData = await isar.assetCaches.where().findAll();
  return {'isOffline': true, 'data': cachedData};
}

// AFTER
} catch (e) {
  debugPrint('❌ Sync error: $e');
  try {
    final cachedData = await isar.assetCaches.where().findAll();
    return {'isOffline': true, 'data': cachedData};
  } catch (cacheError) {
    debugPrint('❌ Fallback cache fetch failed: $cacheError');
    return {'isOffline': true, 'data': const []};
  }
}
```

---

### ISSUE #10: Batch Alert Updates in Background Service

**File:** `lib/core/services/background_service.dart` (Line 82-104)

**Quick Fix:**

```dart
// Create symbol->asset map before loop for O(1) lookup
final assetMap = <String, AssetCache>{};
for (final asset in masterCache) {
  assetMap[asset.symbol] = asset;
}

final alertsToUpdate = <PriceAlert>[];

for (var alert in activeAlerts) {
  final asset = assetMap[alert.symbol];  // O(1) instead of O(n)

  if (asset != null) {
    bool isTriggered = false;
    if (alert.isAbove && asset.currentPrice >= alert.targetPrice) {
      isTriggered = true;
    } else if (!alert.isAbove && asset.currentPrice <= alert.targetPrice) {
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

// Batch update all at once
if (alertsToUpdate.isNotEmpty) {
  await isar.priceAlerts.putAll(alertsToUpdate);
}
```

---

## Priority Implementation Order

✅ **Phase 1 (30 mins)** - Do These First:

1. Issue #2: Add error logging (1 file change)
2. Issue #1: Fix CryptoRepository nulls (1 file change)
3. Issue #6: Fix IsarService.openDB() (1 file change)

⚠️ **Phase 2 (1 hour)** - Do Next: 4. Issue #3: Optimize alert lookup in MarketSyncUseCase 5. Issue #10: Batch alert updates in background_service 6. Issue #4: Validate ForexRepository

📋 **Phase 3 (1 hour)** - Complete Polish: 7. Issue #7: Protect all writeTxn calls 8. Issue #8: Optimize category updates 9. Issue #5: Fix StocksRepository catch

---

## Testing After Fixes

Run after each phase:

```bash
# Unit tests
flutter test

# Check for memory leaks
flutter run --profile

# Run in DevTools Memory tab and monitor growth

# Background service test
adb shell am broadcast -a com.example.tideview.SYNC_TEST
```

---

## Files to Modify (in order)

1. `lib/core/services/background_service.dart` (2 fixes)
2. `lib/core/repositories/crypto_repository.dart` (1 fix)
3. `lib/core/services/isar_service.dart` (4 fixes)
4. `lib/core/usecases/market_sync_usecase.dart` (2 fixes)
5. `lib/core/repositories/forex_repository.dart` (1 fix)
6. `lib/core/repositories/stocks_repository.dart` (1 fix)

---

**Total Implementation Time:** 3-4 hours  
**Risk Level:** LOW (isolated changes, no architecture changes)  
**Testing Time:** 2 hours
