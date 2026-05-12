import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/alert_provider.dart';
import '../../shared/widgets/price_alert_bottom_sheet.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';

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
          HapticFeedback.selectionClick();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const PriceAlertBottomSheet(),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
        label: const Text(
          'New Alert',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noAlerts,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isAbove = alert.isAbove;
              final formattedTarget = CurrencyFormatter.format(
                alert.targetPrice,
                baseCurrency,
                rate,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(alert.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    HapticFeedback.mediumImpact();
                    ref.read(alertProvider.notifier).deleteAlert(alert.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.alertDeleted),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isAbove
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
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
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(alertProvider.notifier)
                              .toggleAlert(alert.id);
                        },
                      ),
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
