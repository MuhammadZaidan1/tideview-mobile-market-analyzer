import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:tideview/core/database/user_prefs.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/color_constants.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/database/asset_cache.dart';
import '../../shared/screens/asset_selector_screen.dart';
import 'manage_alerts_screen.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/custom_popup.dart';

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
    CustomPopup.showAppBottomSheet(
      context: context,
      child: Builder(
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
                          if (context.mounted) {
                            Navigator.pop(bottomSheetContext);
                          }
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
      ),
    );
  }

  Future<void> _clearCache() async {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomPopup(
        title: l10n.clearCacheConfirmTitle,
        message: l10n.clearCacheConfirmMessage,
        type: PopupType.caution,
        confirmLabel: l10n.yesClear,
        cancelLabel: l10n.cancel,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    HapticFeedback.heavyImpact();
    CustomPopup.showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      child: const Center(child: CircularProgressIndicator()),
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
        Navigator.pop(context);
        CustomPopup.showAppDialog<void>(
          context: context,
          title: 'Success',
          message: l10n.cacheSuccess,
          type: PopupType.success,
          confirmLabel: l10n.ok,
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showLoginBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    CustomPopup.showAppBottomSheet(
      context: context,
      child: SafeArea(
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
                l10n.loginTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await signInWithGoogle();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${l10n.loginFailed}: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: Text(l10n.continueWithGoogle),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await signInWithGithub();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${l10n.loginFailed}: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.code_rounded, size: 22),
                  label: Text(l10n.continueWithGithub),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageAccountBottomSheet(BuildContext context, User user) {
    final l10n = AppLocalizations.of(context)!;
    final provider = user.appMetadata['provider']?.toString() ?? '-';

    CustomPopup.showAppBottomSheet(
      context: context,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.manageAccount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _AccountInfoRow(label: l10n.loggedInAs, value: user.email ?? '-'),
              const SizedBox(height: 12),
              _AccountInfoRow(
                label: 'Sign-in method',
                value: provider[0].toUpperCase() + provider.substring(1),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final confirm = await CustomPopup.showAppDialog<bool>(
                      context: context,
                      title: l10n.logOutConfirmTitle,
                      message: l10n.logOutConfirmMessage,
                      type: PopupType.caution,
                      confirmLabel: l10n.yesLogOut,
                      cancelLabel: l10n.cancel,
                      onConfirm: () => Navigator.pop(context, true),
                    );
                    if (confirm == true) {
                      await signOut();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: Text(
                    l10n.logOut,
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              _SettingsSectionHeader(title: 'Account'),
              _SettingsSectionCard(
                child: Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(currentUserProvider);
                    if (user == null) {
                      return _SettingsOptionTile(
                        leadingIcon: Icon(
                          Icons.login_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: l10n.notLoggedIn,
                        subtitle: Text(l10n.tapToLogin),
                        onTap: () => _showLoginBottomSheet(context),
                      );
                    }
                    return _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.account_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: user.email ?? l10n.loggedInAs,
                      subtitle: Text(l10n.manageAccount),
                      onTap: () => _showManageAccountBottomSheet(context, user),
                    );
                  },
                ),
              ),
              _SettingsSectionHeader(title: l10n.appearance),
              _SettingsSectionCard(
                child: Column(
                  children: [
                    _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.dark_mode_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.appTheme,
                      trailingWidget: DropdownButtonHideUnderline(
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
                    _SettingsSectionDivider(),
                    _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.palette_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.themeColor,
                      trailingWidget: Row(
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
              _SettingsSectionHeader(title: l10n.notifications),
              _SettingsSectionCard(
                child: _SettingsOptionTile(
                  leadingIcon: Icon(
                    Icons.notifications_active_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: l10n.manageAlerts,
                  trailingWidget: const Icon(
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
              _SettingsSectionHeader(title: l10n.widgetManagement),
              _SettingsSectionCard(
                child: Column(
                  children: [
                    _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.widgets_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.selectedAsset,
                      trailingWidget: Row(
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
                    _SettingsSectionDivider(),
                    _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.sync_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.widgetSyncRate,
                      trailingWidget: DropdownButtonHideUnderline(
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
              _SettingsSectionHeader(title: l10n.preferences),
              _SettingsSectionCard(
                child: Column(
                  children: [
                    _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.language_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.language,
                      trailingWidget: DropdownButtonHideUnderline(
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
                    _SettingsSectionDivider(),
                    _SettingsOptionTile(
                      leadingIcon: Icon(
                        Icons.attach_money_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.baseCurrency,
                      trailingWidget: DropdownButtonHideUnderline(
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
              _SettingsSectionHeader(title: l10n.dataManagement),
              _SettingsSectionCard(
                child: _SettingsOptionTile(
                  leadingIcon: Container(
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
                  title: l10n.clearCache,
                  titleStyle: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  subtitle: Text(
                    l10n.cacheSubtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailingWidget: const Icon(
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

class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
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
}

class _SettingsSectionCard extends StatelessWidget {
  final Widget child;

  const _SettingsSectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: child,
    );
  }
}

class _SettingsOptionTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final TextStyle? titleStyle;
  final Widget? subtitle;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const _SettingsOptionTile({
    required this.leadingIcon,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon,
      title: Text(
        title,
        style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle,
      trailing: trailingWidget,
      onTap: onTap,
    );
  }
}

class _SettingsSectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
