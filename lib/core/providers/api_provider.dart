import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../repositories/crypto_repository.dart';
import '../repositories/forex_repository.dart';
import '../repositories/stocks_repository.dart';
import '../services/isar_service.dart';
import '../usecases/market_sync_usecase.dart';
import '../database/watchlist_category.dart';
import '../theme/theme_provider.dart';

final cryptoRepoProvider = Provider((ref) => CryptoRepository());
final forexRepoProvider = Provider((ref) => ForexRepository());
final stocksRepoProvider = Provider((ref) => StocksRepository());

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

MarketSyncUseCase? _marketSyncInstance;

final marketSyncProvider = Provider<MarketSyncUseCase>((ref) {
  _marketSyncInstance ??= MarketSyncUseCase(
    apiRepo: ref.watch(cryptoRepoProvider),
    isarService: ref.watch(isarServiceProvider),
  );
  return _marketSyncInstance!;
});

Future<void> forceRefreshAllMarkets(WidgetRef ref) async {
  final useCase = ref.read(marketSyncProvider);
  await useCase.getCryptoData(forceRefresh: true);
  ref.invalidate(cryptoDataProvider);
  ref.invalidate(forexDataProvider);
  ref.invalidate(stockDataProvider);
}

final cryptoDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final syncInterval = ref.watch(
    themeProvider.select((t) => t.valueOrNull?.syncIntervalMinutes ?? 15),
  );

  final timer = Timer(Duration(minutes: syncInterval), () {
    ref.invalidateSelf();
  });

  ref.onDispose(() => timer.cancel());

  final useCase = ref.watch(marketSyncProvider);
  return useCase.getCryptoData();
});

final forexDataProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final syncInterval = ref.watch(
    themeProvider.select((t) => t.valueOrNull?.syncIntervalMinutes ?? 15),
  );
  final timer = Timer(Duration(minutes: syncInterval), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());

  final repo = ref.watch(forexRepoProvider);
  return repo.fetchForexMarkets();
});

final stockDataProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final syncInterval = ref.watch(
    themeProvider.select((t) => t.valueOrNull?.syncIntervalMinutes ?? 15),
  );
  final timer = Timer(Duration(minutes: syncInterval), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());

  final repo = ref.watch(stocksRepoProvider);
  return repo.fetchStockMarkets();
});

final watchlistCategoriesProvider = FutureProvider<List<WatchlistCategory>>((
  ref,
) async {
  final isarService = ref.watch(isarServiceProvider);
  final isar = await isarService.db;
  return await isar.watchlistCategorys.where().findAll();
});
