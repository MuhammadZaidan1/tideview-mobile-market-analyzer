import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/database/asset_cache.dart';
import '../../core/database/price_alert.dart';
import '../../core/services/isar_service.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../screens/asset_selector_screen.dart';

class PriceAlertBottomSheet extends ConsumerStatefulWidget {
  final AssetCache? initialAsset;
  const PriceAlertBottomSheet({super.key, this.initialAsset});
  @override
  ConsumerState<PriceAlertBottomSheet> createState() =>
      _PriceAlertBottomSheetState();
}

class _PriceAlertBottomSheetState extends ConsumerState<PriceAlertBottomSheet> {
  AssetCache? _selectedAsset;
  bool _isAbove = true;
  final TextEditingController _priceController = TextEditingController();
  final IsarService _isarService = IsarService();

  @override
  void initState() {
    super.initState();
    _selectedAsset = widget.initialAsset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedAsset != null && mounted) {
        final rate = ref.read(exchangeRateProvider).valueOrNull ?? 1.0;
        final baseCurrency =
            ref.read(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
        final localPrice = _selectedAsset!.currentPrice * rate;
        _priceController.text = localPrice.toStringAsFixed(
          baseCurrency == 'IDR' ? 0 : 2,
        );
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _openAssetSelector() async {
    HapticFeedback.selectionClick();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AssetSelectorScreen(),
        fullscreenDialog: true,
      ),
    );
    if (result != null && result is AssetCache) {
      final rate = ref.read(exchangeRateProvider).valueOrNull ?? 1.0;
      final baseCurrency =
          ref.read(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
      final localPrice = result.currentPrice * rate;
      setState(() {
        _selectedAsset = result;
        _priceController.text = localPrice.toStringAsFixed(
          baseCurrency == 'IDR' ? 0 : 2,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
    String currencySymbol = '\$';
    if (baseCurrency == 'IDR') {
      currencySymbol = 'Rp';
    } else if (baseCurrency == 'EUR') {
      currencySymbol = '€';
    } else if (baseCurrency == 'GBP') {
      currencySymbol = '£';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20, 
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.setPriceAlert,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.priceAlertDescription,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.selectAssetLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _openAssetSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: primaryColor.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      children: [
                        if (_selectedAsset != null) ...[
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              _selectedAsset!.symbol[0],
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedAsset!.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _selectedAsset!.name,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              _selectedAsset!.currentPrice,
                              baseCurrency,
                              rate,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l10n.chooseAssetHint,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.conditionLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isAbove = true);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isAbove
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: _isAbove
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: _isAbove ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: _isAbove ? Colors.green : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    l10n.priceGoesAbove,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: _isAbove
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isAbove = false);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isAbove
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: !_isAbove
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: !_isAbove ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_down_rounded,
                                color: !_isAbove ? Colors.red : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    l10n.priceGoesBelow,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: !_isAbove
                                          ? Colors.red
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Target Price ($baseCurrency)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 48,
                      alignment: Alignment.center,
                      child: Text(
                        currencySymbol,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAsset == null
                        ? null
                        : () async {
                            final targetLocal =
                                double.tryParse(_priceController.text) ?? 0.0;
                            if (targetLocal > 0) {
                              HapticFeedback.heavyImpact();
                              final targetUSD = CurrencyFormatter.toUSD(
                                targetLocal,
                                rate,
                              );
                              final alert = PriceAlert()
                                ..symbol = _selectedAsset!.symbol
                                ..targetPrice = targetUSD
                                ..isAbove = _isAbove
                                ..isActive = true;
                              await _isarService.savePriceAlert(alert);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.alertSavedSuccess),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withValues(
                        alpha: 0.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.setAlarmButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
