import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/api_provider.dart';
import '../../core/database/asset_cache.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/isar_service.dart';
import '../../shared/widgets/asset_card.dart';
import '../asset_detail/asset_detail_screen.dart';
import '../../shared/widgets/price_alert_bottom_sheet.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/asset_search_filter.dart';
import '../../shared/widgets/async_asset_list.dart';

enum MarketSort { az, gainers, losers }

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});
  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Crypto';
  MarketSort _currentSort = MarketSort.az;
  Timer? _autoRefreshTimer; 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (mounted) {
        forceRefreshAllMarkets(ref);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      forceRefreshAllMarkets(ref);
    }
  }

  void _applySort(List<AssetCache> list) {
    switch (_currentSort) {
      case MarketSort.az:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case MarketSort.gainers:
        list.sort((a, b) => b.priceChange24h.compareTo(a.priceChange24h));
        break;
      case MarketSort.losers:
        list.sort((a, b) => a.priceChange24h.compareTo(b.priceChange24h));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cryptoDataAsync = ref.watch(cryptoDataProvider);
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.exploreMarkets,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) =>
                        const PriceAlertBottomSheet(initialAsset: null),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetSearchFilter(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (val) =>
                setState(() => _searchQuery = val.toLowerCase()),
            onClearSearch: () {
              HapticFeedback.lightImpact();
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                FocusScope.of(context).unfocus();
              });
            },
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) =>
                setState(() => _selectedCategory = cat),
            trailingWidget: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: PopupMenuButton<MarketSort>(
                icon: Icon(
                  Icons.tune_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).colorScheme.surface,
                elevation: 4,
                onSelected: (MarketSort result) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentSort = result);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MarketSort>>[
                      PopupMenuItem<MarketSort>(
                        value: MarketSort.az,
                        child: Row(
                          children: [
                            Icon(
                              Icons.sort_by_alpha_rounded,
                              color: _currentSort == MarketSort.az
                                  ? primaryColor
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'A-Z',
                              style: TextStyle(
                                color: _currentSort == MarketSort.az
                                    ? primaryColor
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<MarketSort>(
                        value: MarketSort.gainers,
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: _currentSort == MarketSort.gainers
                                  ? Colors.green
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Top Gainers',
                              style: TextStyle(
                                color: _currentSort == MarketSort.gainers
                                    ? Colors.green
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<MarketSort>(
                        value: MarketSort.losers,
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_down_rounded,
                              color: _currentSort == MarketSort.losers
                                  ? Colors.red
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Top Losers',
                              style: TextStyle(
                                color: _currentSort == MarketSort.losers
                                    ? Colors.red
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await forceRefreshAllMarkets(ref);
              },
              child: AsyncAssetList<Map<String, dynamic>>(
                asyncValue: cryptoDataAsync,
                emptyMessage: l10n.assetNotFound,
                errorMessage: l10n.failedToLoadData,
                builder: (response) {
                  final List<AssetCache> allAssets = response['data'] ?? [];

                  final filtered = allAssets.where((a) {
                    final matchesSearch =
                        a.symbol.toLowerCase().contains(_searchQuery) ||
                        a.name.toLowerCase().contains(_searchQuery);
                    final matchesCategory =
                        a.marketType.toLowerCase() ==
                        _selectedCategory.toLowerCase();
                    return _searchQuery.isNotEmpty
                        ? matchesSearch
                        : matchesCategory;
                  }).toList();

                  _applySort(filtered);

                  if (filtered.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final asset = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssetDetailScreen(asset: asset),
                              ),
                            );
                          },
                          child: AssetCard(
                            name: asset.name,
                            symbol: asset.symbol,
                            formattedPrice: CurrencyFormatter.format(
                              asset.currentPrice,
                              baseCurrency,
                              rate,
                            ),
                            change24h: asset.priceChange24h,
                            trailing: IconButton(
                              icon: Icon(
                                asset.isWatchlisted
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: asset.isWatchlisted
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                await IsarService().toggleWatchlist(
                                  asset.symbol,
                                );
                                ref.invalidate(cryptoDataProvider);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
