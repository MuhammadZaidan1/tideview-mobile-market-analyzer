import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:home_widget/home_widget.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'color_constants.dart';
import '../services/isar_service.dart';
import '../database/user_prefs.dart';
import '../database/schemas.dart';
import '../database/asset_cache.dart';
import '../../shared/utils/currency_formatter.dart';
import '../providers/exchange_rate_provider.dart'; 

class ThemeState {
  final Color accentColor;
  final ThemeMode themeMode;
  final String languageCode;
  final String baseCurrency;
  final int syncIntervalMinutes;
  final String widgetAssetSymbol;
  ThemeState({
    required this.accentColor,
    required this.themeMode,
    required this.languageCode,
    required this.baseCurrency,
    required this.syncIntervalMinutes,
    required this.widgetAssetSymbol,
  });
  ThemeState copyWith({
    Color? accentColor,
    ThemeMode? themeMode,
    String? languageCode,
    String? baseCurrency,
    int? syncIntervalMinutes,
    String? widgetAssetSymbol,
  }) {
    return ThemeState(
      accentColor: accentColor ?? this.accentColor,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      widgetAssetSymbol: widgetAssetSymbol ?? this.widgetAssetSymbol,
    );
  }
}

class ThemeNotifier extends AsyncNotifier<ThemeState> {
  late final IsarService _isarService;
  @override
  Future<ThemeState> build() async {
    _isarService = IsarService();
    final prefs = await _isarService.getUserPrefs();
    if (prefs != null) {
      final accentColor = _hexToColor(prefs.activeThemeHex);
      final themeMode = prefs.isDarkMode ? ThemeMode.dark : ThemeMode.system;
      int rawInterval = prefs.syncIntervalMinutes;
      int safeInterval = [15, 30, 60].contains(rawInterval) ? rawInterval : 15;
      return ThemeState(
        accentColor: accentColor,
        themeMode: themeMode,
        languageCode: prefs.languageCode,
        baseCurrency: prefs.baseCurrency,
        syncIntervalMinutes: safeInterval,
        widgetAssetSymbol: prefs.widgetAssetSymbol,
      );
    } else {
      return ThemeState(
        accentColor: AppColors.royalPurplePrimary,
        themeMode: ThemeMode.system,
        languageCode: 'en',
        baseCurrency: 'USD',
        syncIntervalMinutes: 15,
        widgetAssetSymbol: 'BTC',
      );
    }
  }
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  Future<void> _saveStateToIsar(ThemeState currentState) async {
    final prefs = UserPrefs()
      ..id = 1
      ..activeThemeHex = _colorToHex(currentState.accentColor)
      ..isDarkMode = currentState.themeMode == ThemeMode.dark
      ..languageCode = currentState.languageCode
      ..baseCurrency = currentState.baseCurrency
      ..syncIntervalMinutes = currentState.syncIntervalMinutes
      ..widgetAssetSymbol = currentState.widgetAssetSymbol;
    await _isarService.saveUserPrefs(prefs);
  }
  Future<void> setAccentColor(Color color) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final newState = currentState.copyWith(accentColor: color);
    state = AsyncValue.data(newState);
    await _saveStateToIsar(newState);
  }
  Future<void> setThemeMode(ThemeMode mode) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final newState = currentState.copyWith(themeMode: mode);
    state = AsyncValue.data(newState);
    await _saveStateToIsar(newState);
  }
  Future<void> setLanguageCode(String languageCode) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final newState = currentState.copyWith(languageCode: languageCode);
    state = AsyncValue.data(newState);
    await _saveStateToIsar(newState);
  }
  Future<void> setBaseCurrency(String baseCurrency) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final newState = currentState.copyWith(baseCurrency: baseCurrency);
    state = AsyncValue.data(newState);
    await _saveStateToIsar(newState);
    await ref
        .read(exchangeRateProvider.notifier)
        .fetchAndUpdateRate(baseCurrency);
    await setWidgetAssetSymbol(currentState.widgetAssetSymbol);
  }
  Future<void> setWidgetAssetSymbol(String symbol) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final newState = currentState.copyWith(widgetAssetSymbol: symbol);
    state = AsyncValue.data(newState);
    await _saveStateToIsar(newState);
    try {
      await HomeWidget.saveWidgetData<String>('widget_name', 'Loading...');
      await HomeWidget.saveWidgetData<String>('widget_symbol', symbol);
      await HomeWidget.saveWidgetData<String>('widget_price', 'Syncing...');
      await HomeWidget.saveWidgetData<String>('widget_change', '-');
      await HomeWidget.updateWidget(
        name: 'TideWidgetProvider',
        androidName: 'TideWidgetProvider',
      );
      final dir = await getApplicationDocumentsDirectory();
      final isar =
          Isar.getInstance() ??
          await Isar.open(appSchemas, directory: dir.path);
      final targetAsset = await isar.assetCaches
          .filter()
          .symbolEqualTo(symbol, caseSensitive: false)
          .findFirst();
      if (targetAsset != null) {
        final prefs = await isar.userPrefs.get(1);
        final targetCurrency = prefs?.baseCurrency ?? 'USD';
        final exchangeRate = prefs?.exchangeRate ?? 1.0;
        final price = CurrencyFormatter.format(
          targetAsset.currentPrice,
          targetCurrency,
          exchangeRate,
        );
        final change =
            '${targetAsset.priceChange24h >= 0 ? '+' : ''}${targetAsset.priceChange24h.toStringAsFixed(2)}%';
        await HomeWidget.saveWidgetData<String>(
          'widget_name',
          targetAsset.name,
        );
        await HomeWidget.saveWidgetData<String>(
          'widget_symbol',
          targetAsset.symbol,
        );
        await HomeWidget.saveWidgetData<String>('widget_price', price);
        await HomeWidget.saveWidgetData<String>('widget_change', change);
        await HomeWidget.updateWidget(
          name: 'TideWidgetProvider',
          androidName: 'TideWidgetProvider',
        );
      }
    } catch (e) {
    }
  }
  Future<void> setSyncInterval(int minutes) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final newState = currentState.copyWith(syncIntervalMinutes: minutes);
    state = AsyncValue.data(newState);
    await _saveStateToIsar(newState);
    await Workmanager().cancelByUniqueName("tideview-sync-task-1");
    await Workmanager().registerPeriodicTask(
      "tideview-sync-task-1",
      "marketSync",
      frequency: Duration(minutes: minutes),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});
