import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:home_widget/home_widget.dart' hide callbackDispatcher;
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes.dart';
import 'core/services/background_service.dart';
import 'core/database/schemas.dart';
import 'core/database/user_prefs.dart';
import 'core/database/asset_cache.dart';
import 'features/asset_detail/asset_detail_screen.dart';
import 'core/services/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
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
  }
  void _listenToWidgetClick() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleDeepLink);
    HomeWidget.widgetClicked.listen(_handleDeepLink);
  }
  void _handleDeepLink(Uri? uri) async {
    if (uri != null && uri.scheme == 'tideview' && uri.host == 'asset') {
      final symbol = uri.queryParameters['symbol'];
      if (symbol != null) {
        final isar = Isar.getInstance()!;
        final targetAsset = await isar.assetCaches
            .filter()
            .symbolEqualTo(symbol, caseSensitive: false)
            .findFirst();
        if (targetAsset != null && _navigatorKey.currentState != null) {
          _navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => AssetDetailScreen(asset: targetAsset),
            ),
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    return themeAsync.when(
      data: (themeState) => MaterialApp(
        navigatorKey: _navigatorKey,
        key: const ValueKey('AppLoaded'),
        title: 'TideView',
        debugShowCheckedModeBanner: false,
        locale: Locale(themeState.languageCode),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('id')],
        theme: AppTheme.getTheme(
          accentColor: themeState.accentColor,
          isDarkMode: false,
        ),
        darkTheme: AppTheme.getTheme(
          accentColor: themeState.accentColor,
          isDarkMode: true,
        ),
        themeMode: themeState.themeMode,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
      loading: () => const MaterialApp(
        key: ValueKey('AppLoading'),
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        key: ValueKey('AppError'),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('Error loading theme: $error')),
        ),
      ),
    );
  }
}
