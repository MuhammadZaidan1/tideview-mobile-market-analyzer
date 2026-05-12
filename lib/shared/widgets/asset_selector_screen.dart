import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'asset_card.dart';
import 'custom_shimmer.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/database/asset_cache.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
    String getLocalizedCategory(String cat) {
      switch (cat) {
        case 'Crypto':
          return l10n.cryptoCategory;
        case 'Stocks':
          return l10n.stocksCategory;
        case 'Forex':
          return l10n.forexCategory;
        default:
          return cat;
      }
    }
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: l10n.searchAssets,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Crypto', 'Stocks', 'Forex'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(getLocalizedCategory(cat)),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _selectedCategory = cat),
                    selectedColor: primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: cryptoDataAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 8,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CustomShimmer(height: 80, borderRadius: 20),
                ),
              ),
              error: (err, stack) => Center(child: Text(l10n.failedToLoadData)),
              data: (response) {
                final List<AssetCache> allAssets = response['data'] ?? [];
                final filtered = allAssets.where((a) {
                  final matchesSearch =
                      a.symbol.toLowerCase().contains(_searchQuery) ||
                      a.name.toLowerCase().contains(_searchQuery);
                  final matchesCategory =
                      a.marketType.toLowerCase() ==
                      _selectedCategory.toLowerCase();
                  return matchesSearch && matchesCategory;
                }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.assetNotFound,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final asset = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, asset),
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
