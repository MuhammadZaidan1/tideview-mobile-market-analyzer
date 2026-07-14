import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/crypto_repository.dart';
import '../repositories/forex_repository.dart';
import '../repositories/stocks_repository.dart';
import '../services/isar_service.dart';
import '../services/supabase_service.dart';
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

// ============================================================
// BARU (Fase 2 migrasi Supabase): realtime subscription ke table `assets`.
// Watch provider ini di widget mana pun (misal MainLayout atau Dashboard)
// biar update harga real-time otomatis nge-trigger refresh data lokal,
// tanpa perlu nunggu Timer polling di atas.
//
// CATATAN OPTIMASI (belum diterapkan, dicatat buat nanti): subscription ini
// masih dengerin SELURUH table `assets` (bukan cuma symbol yang lagi
// ditampilkan). Di skala kecil ini gak masalah, tapi kalau user makin
// banyak, sebaiknya di-filter cuma ke symbol yang relevan biar gak boros
// kuota "2 juta message realtime/bulan" di free tier Supabase.
final realtimeAssetsProvider = StreamProvider.autoDispose<void>((ref) {
  final controller = StreamController<void>();

  debugPrint('[Realtime] Mulai subscribe ke channel public:assets...');

  final channel = supabase
      .channel('public:assets')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'assets',
        callback: (payload) async {
          debugPrint(
            '[Realtime] EVENT DITERIMA: ${payload.eventType} -- '
            'record baru: ${payload.newRecord}',
          );

          final useCase = ref.read(marketSyncProvider);
          await useCase.getCryptoData(forceRefresh: true);
          ref.invalidate(cryptoDataProvider);
          ref.invalidate(forexDataProvider);
          ref.invalidate(stockDataProvider);
          if (!controller.isClosed) controller.add(null);

          debugPrint('[Realtime] Selesai forceRefresh + invalidate provider');
        },
      )
      .subscribe((status, error) {
        debugPrint('[Realtime] Status subscribe berubah: $status');
        if (error != null) {
          debugPrint('[Realtime] ERROR pas subscribe: $error');
        }
      });

  ref.onDispose(() {
    debugPrint('[Realtime] Dispose channel public:assets');
    supabase.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});
