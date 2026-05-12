import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../repositories/crypto_repository.dart';
import '../repositories/forex_repository.dart';
import '../repositories/stocks_repository.dart';
import '../services/isar_service.dart';
import '../usecases/market_sync_usecase.dart';
import '../database/watchlist_category.dart';

final cryptoRepoProvider = Provider((ref) => CryptoRepository());
final forexRepoProvider = Provider((ref) => ForexRepository());
final stocksRepoProvider = Provider((ref) => StocksRepository());
final isarServiceProvider = Provider((ref) => IsarService());

final marketSyncProvider = Provider((ref) {
  return MarketSyncUseCase(
    apiRepo: ref.watch(cryptoRepoProvider),
    isarService: ref.watch(isarServiceProvider),
  );
});

final cryptoDataProvider = FutureProvider((ref) async {
  final useCase = ref.watch(marketSyncProvider);
  return useCase.getCryptoData();
});

final forexDataProvider = FutureProvider((ref) async {
  final repo = ref.watch(forexRepoProvider);
  return repo.fetchForexMarkets();
});

final stockDataProvider = FutureProvider((ref) async {
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
