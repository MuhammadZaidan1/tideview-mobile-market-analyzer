import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/asset_card.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/database/asset_cache.dart';
import '../utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../widgets/asset_search_filter.dart';
import '../widgets/async_asset_list.dart';

class AssetSelectorScreen extends ConsumerStatefulWidget {
  const AssetSelectorScreen({super.key});
  @override
  ConsumerState<AssetSelectorScreen> createState() =>
      _AssetSelectorScreenState();
}

class _AssetSelectorScreenState extends ConsumerState<AssetSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Crypto';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cryptoDataAsync = ref.watch(cryptoDataProvider);
    final l10n = AppLocalizations.of(context)!;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.selectAsset,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
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
          ),

          Expanded(
            child: AsyncAssetList<Map<String, dynamic>>(
              asyncValue: cryptoDataAsync,
              shimmerHeight: 80,
              shimmerCount: 8,
              padding: const EdgeInsets.all(16),
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

                if (filtered.isEmpty)
                  return const SizedBox.shrink(); 

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final asset = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context, asset);
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
