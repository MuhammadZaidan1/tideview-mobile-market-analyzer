import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:tideview/core/database/user_prefs.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/color_constants.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/database/asset_cache.dart';
import '../../shared/widgets/asset_selector_screen.dart';
import 'manage_alerts_screen.dart';
import '../../core/providers/api_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late int _selectedColorIndex;
  late String _selectedLanguage;
  late String _selectedCurrency;
  final List<Color> _themeColors = [
    AppColors.royalPurplePrimary,
    AppColors.cyberGreenPrimary,
    AppColors.sunsetOrangePrimary,
    AppColors.electricCyanPrimary,
    AppColors.hotMagentaPrimary,
  ];
  int _getColorIndex(Color color) {
    for (int i = 0; i < _themeColors.length; i++) {
      if (_themeColors[i] == color) return i;
    }
    return 0;
  }
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }
  ThemeMode _stringToThemeMode(String modeStr) {
    switch (modeStr) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System Default':
      default:
        return ThemeMode.system;
    }
  }
  void _showColorPickerBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (bottomSheetContext) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  l10n.selectThemeColor,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: List.generate(_themeColors.length, (index) {
                    final color = _themeColors[index];
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedColorIndex = index);
                        await ref
                            .read(themeProvider.notifier)
                            .setAccentColor(color);
                        if (context.mounted) Navigator.pop(bottomSheetContext);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 56 : 48,
                        height: isSelected ? 56 : 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _clearCache() async {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final isar = Isar.getInstance();
      if (isar != null) {
        await isar.writeTxn(() async {
          await isar.assetCaches.clear();
          final prefs = await isar.userPrefs.get(1);
          if (prefs != null) {
            prefs.lastCryptoSyncTime = null;
            await isar.userPrefs.put(prefs);
          }
        });
      }
      ref.invalidate(cryptoDataProvider);
      ref.invalidate(watchlistCategoriesProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cacheSuccess),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 24),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  BoxDecoration _boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeAsync = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    return themeAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (themeState) {
        _selectedColorIndex = _getColorIndex(themeState.accentColor);
        _selectedLanguage = themeState.languageCode == 'id'
            ? 'Indonesian'
            : 'English';
        _selectedCurrency = themeState.baseCurrency;
        final currentThemeModeStr = _themeModeToString(themeState.themeMode);
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(
              l10n.settings,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionHeader(l10n.appearance),
              Container(
                decoration: _boxDecoration(context),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.dark_mode_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        l10n.appTheme,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentThemeModeStr,
                          alignment: Alignment.centerRight,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          items: ['System Default', 'Light', 'Dark']
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m == 'System Default'
                                        ? l10n.systemDefault
                                        : (m == 'Light'
                                              ? l10n.light
                                              : l10n.dark),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) async {
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              await ref
                                  .read(themeProvider.notifier)
                                  .setThemeMode(_stringToThemeMode(val));
                            }
                          },
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.05),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.palette_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        l10n.themeColor,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: themeState.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: themeState.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      onTap: () => _showColorPickerBottomSheet(context, ref),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(l10n.notifications),
              Container(
                decoration: _boxDecoration(context),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    l10n.manageAlerts,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageAlertsScreen(),
                      ),
                    );
                  },
                ),
              ),
              _buildSectionHeader(l10n.widgetManagement),
              Container(
                decoration: _boxDecoration(context),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.widgets_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        l10n.selectedAsset,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            themeState.widgetAssetSymbol,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AssetSelectorScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                        if (result != null && result is AssetCache) {
                          await ref
                              .read(themeProvider.notifier)
                              .setWidgetAssetSymbol(result.symbol);
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.05),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.sync_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        l10n.widgetSyncRate,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: themeState.syncIntervalMinutes,
                          alignment: Alignment.centerRight,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 15,
                              child: Text(
                                l10n.sync15Min,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text(
                                l10n.sync30Min,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 60,
                              child: Text(
                                l10n.sync1Hour,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                          onChanged: (val) async {
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              await ref
                                  .read(themeProvider.notifier)
                                  .setSyncInterval(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(l10n.preferences),
              Container(
                decoration: _boxDecoration(context),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.language_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        l10n.language,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          alignment: Alignment.centerRight,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          items: ['English', 'Indonesian']
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(
                                    l,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) async {
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedLanguage = val);
                              final langCode = val == 'Indonesian'
                                  ? 'id'
                                  : 'en';
                              await ref
                                  .read(themeProvider.notifier)
                                  .setLanguageCode(langCode);
                            }
                          },
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.05),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.attach_money_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        l10n.baseCurrency,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          alignment: Alignment.centerRight,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          items: ['USD', 'IDR', 'EUR', 'GBP']
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) async {
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCurrency = val);
                              await ref
                                  .read(themeProvider.notifier)
                                  .setBaseCurrency(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(l10n.dataManagement),
              Container(
                decoration: _boxDecoration(context),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.clearCache,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    l10n.cacheSubtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: _clearCache,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
