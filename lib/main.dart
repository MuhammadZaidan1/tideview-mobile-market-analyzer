import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_widget/home_widget.dart' hide callbackDispatcher;
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes.dart';
import 'core/services/background_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/isar_service.dart';
import 'core/providers/api_provider.dart';
import 'core/database/schemas.dart';
import 'core/database/user_prefs.dart';
import 'core/database/asset_cache.dart';
import 'core/services/notification_helper.dart';
import 'core/repositories/crypto_repository.dart';
import 'shared/utils/currency_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  await initSupabase();

  final dir = await getApplicationDocumentsDirectory();
  final isar = Isar.instanceNames.isEmpty
      ? await Isar.open(appSchemas, directory: dir.path)
      : Isar.getInstance()!;

  final prefs = await isar.userPrefs.get(1);
  final syncInterval = prefs?.syncIntervalMinutes ?? 15;

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "tideview-sync-task-1",
    "marketSync",
    frequency: Duration(minutes: syncInterval),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _listenToWidgetClick();
    _listenToAuthChanges();
    Future.microtask(() => _initFirstBootWidgetSync());
  }

  void _listenToAuthChanges() {
    // Tiap kali ada event login (baru login di Settings, atau resume sesi
    // yang udah ada sebelumnya), sync watchlist/kategori/alert lokal <-> akun.
    supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        await IsarService().syncCloudDataOnLogin();
        _invalidateMarketProviders();

        // syncCloudDataOnLogin() punya beberapa "reapply pass" internal
        // (2/4/7/11/15 detik) buat ngalahin race condition sama market
        // sync -- invalidate provider juga berkali-kali matching timing itu,
        // biar UI ikut ke-refresh begitu salah satu pass berhasil benerin data.
        for (final delaySeconds in [3, 5, 8, 12, 16]) {
          Future.delayed(Duration(seconds: delaySeconds), () {
            _invalidateMarketProviders();
          });
        }
      }
    });
  }

  void _invalidateMarketProviders() {
    if (!mounted) return;
    ref.invalidate(cryptoDataProvider);
    ref.invalidate(forexDataProvider);
    ref.invalidate(stockDataProvider);
    ref.invalidate(watchlistCategoriesProvider);
  }

  Future<void> _initFirstBootWidgetSync() async {
    final isar = Isar.getInstance()!;
    final assetCount = await isar.assetCaches.count();
    if (assetCount == 0) {
      try {
        final cryptoRepo = CryptoRepository();
        final markets = await cryptoRepo.fetchCryptoMarkets();
        final btcData = markets.firstWhere(
          (m) => m['symbol'].toString().toLowerCase() == 'btc',
          orElse: () => {},
        );

        if (btcData.isNotEmpty) {
          final btcAsset = AssetCache()
            ..symbol = btcData['symbol']
            ..name = btcData['name']
            ..currentPrice = (btcData['current_price'] as num).toDouble()
            ..priceChange24h = (btcData['price_change_percentage_24h'] as num)
                .toDouble()
            ..image = btcData['image']
            ..marketType = 'Crypto'
            ..lastUpdated = DateTime.now();
          await isar.writeTxn(() async {
            await isar.assetCaches.put(btcAsset);
          });
          final prefs = await isar.userPrefs.get(1);
          final targetCurrency = prefs?.baseCurrency ?? 'USD';
          final rate = prefs?.exchangeRate ?? 1.0;
          final formattedPrice = CurrencyFormatter.format(
            btcAsset.currentPrice,
            targetCurrency,
            rate,
          );
          final formattedChange =
              "${btcAsset.priceChange24h >= 0 ? '+' : ''}${btcAsset.priceChange24h.toStringAsFixed(2)}%";
          await HomeWidget.saveWidgetData<String>('widget_name', btcAsset.name);
          await HomeWidget.saveWidgetData<String>(
            'widget_symbol',
            btcAsset.symbol,
          );
          await HomeWidget.saveWidgetData<String>(
            'widget_price',
            formattedPrice,
          );
          await HomeWidget.saveWidgetData<String>(
            'widget_change',
            formattedChange,
          );

          await HomeWidget.updateWidget(
            name: 'TideWidgetProvider',
            androidName: 'TideWidgetProvider',
          );
        }
      } catch (e) {
        // Silently fail
      }
    }
  }

  void _listenToWidgetClick() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleDeepLink);
    HomeWidget.widgetClicked.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri? uri) async {
    if (uri != null && uri.scheme == 'tideview' && uri.host == 'asset') {
      final symbol = uri.queryParameters['symbol'];
      if (symbol != null) {
        await Future.delayed(const Duration(milliseconds: 800));

        final isar = Isar.getInstance()!;
        final targetAsset = await isar.assetCaches
            .filter()
            .symbolEqualTo(symbol, caseSensitive: false)
            .findFirst();

        if (targetAsset != null && _navigatorKey.currentState != null) {
          _navigatorKey.currentState!.pushNamed(
            AppRoutes.assetDetail,
            arguments: targetAsset,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'TideView',
      debugShowCheckedModeBanner: false,
      locale: themeAsync.valueOrNull != null
          ? Locale(themeAsync.valueOrNull!.languageCode)
          : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      theme: AppTheme.getTheme(
        accentColor: themeAsync.valueOrNull?.accentColor ?? Colors.blue,
        isDarkMode: false,
      ),
      darkTheme: AppTheme.getTheme(
        accentColor: themeAsync.valueOrNull?.accentColor ?? Colors.blue,
        isDarkMode: true,
      ),
      themeMode: themeAsync.valueOrNull?.themeMode ?? ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      builder: (context, child) {
        return themeAsync.when(
          data: (_) => child!,
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Error loading theme: $error')),
          ),
        );
      },
    );
  }
}
