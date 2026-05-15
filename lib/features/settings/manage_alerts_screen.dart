import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/alert_provider.dart';
import '../../shared/widgets/price_alert_bottom_sheet.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/database/price_alert.dart';
import '../../shared/widgets/async_asset_list.dart';

class ManageAlertsScreen extends ConsumerWidget {
  const ManageAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertProvider);
    final l10n = AppLocalizations.of(context)!;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.manageAlerts,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                const PriceAlertBottomSheet(initialAsset: null),
          );
        },
        label: Text(l10n.addAlert),
        icon: const Icon(Icons.add_alert_rounded),
      ),
      body: AsyncAssetList<List<PriceAlert>>(
        asyncValue: alertsAsync,
        shimmerHeight: 90,
        emptyMessage: l10n.noAlertsSet,
        builder: (alerts) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isAbove = alert.isAbove;
              final formattedTarget = CurrencyFormatter.format(
                alert.targetPrice,
                baseCurrency,
                rate,
              );

              return Dismissible(
                key: ValueKey(alert.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.red,
                  ),
                ),
                onDismissed: (_) {
                  HapticFeedback.mediumImpact();
                  ref.read(alertProvider.notifier).deleteAlert(alert.id);
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isAbove ? Colors.green : Colors.red).withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAbove
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: isAbove ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      alert.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${isAbove ? l10n.priceAbove : l10n.priceBelow} $formattedTarget',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: alert.isActive,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        ref.read(alertProvider.notifier).toggleAlert(alert.id);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
