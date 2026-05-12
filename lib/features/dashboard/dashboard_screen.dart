import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../asset_detail/asset_detail_screen.dart';
import '../../core/providers/api_provider.dart';
import '../../../core/database/asset_cache.dart';
import '../../../core/database/watchlist_category.dart';
import '../../../core/services/isar_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/asset_card.dart';
import '../../../shared/widgets/custom_shimmer.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/price_alert_bottom_sheet.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/providers/exchange_rate_provider.dart';
import '../../../core/theme/theme_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<AssetCache> _localAssets = [];
  List<AssetCache> _allWatchlistedAssets = [];
  bool _isOffline = false;
  String _activeCategory = 'allCategory';
  Future<void> _saveSortOrderToIsar(List<AssetCache> assets) async {
    try {
      if (Isar.instanceNames.isNotEmpty) {
        final isarInstance = Isar.getInstance();
        if (isarInstance == null) return;
        for (int i = 0; i < assets.length; i++) {
          assets[i].sortOrder = i;
        }
        await isarInstance.writeTxn(() async {
          await isarInstance.assetCaches.putAll(assets);
        });
      }
    } catch (e) {
    }
  }
  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.createNewCategory,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.categoryExample,
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final navigatorContext = context;
                await IsarService().createCustomCategory(name);
                final _ = ref.refresh(watchlistCategoriesProvider);
                if (mounted) Navigator.pop(navigatorContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
  void _showEditCategoryAssetsSheet(String categoryName) {
    final List<AssetCache> localEditList = List.from(_allWatchlistedAssets);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)!.editCategory} "$categoryName"',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: localEditList.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.emptyWatchlistMessage,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: localEditList.length,
                              itemBuilder: (context, index) {
                                final asset = localEditList[index];
                                final isSelected = asset.customCategories
                                    .contains(categoryName);
                                return CheckboxListTile(
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  title: Text(
                                    asset.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(asset.symbol),
                                  secondary: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      asset.symbol[0],
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  value: isSelected,
                                  onChanged: (val) async {
                                    HapticFeedback.lightImpact();
                                    await IsarService()
                                        .toggleAssetCustomCategory(
                                          asset.symbol,
                                          categoryName,
                                        );
                                    setModalState(() {
                                      if (val == true) {
                                        asset.customCategories = List.from(
                                          asset.customCategories,
                                        )..add(categoryName);
                                      } else {
                                        asset.customCategories = List.from(
                                          asset.customCategories,
                                        )..remove(categoryName);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      ref.invalidate(cryptoDataProvider);
    });
  }

  void _showReorderCategoriesSheet(List<WatchlistCategory> currentCategories) {
    List<WatchlistCategory> reorderList = List.from(currentCategories);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Tahan dan geser untuk mengurutkan Playlist',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: reorderList.length,
                    onReorder: (oldIndex, newIndex) {
                      HapticFeedback.selectionClick();
                      setModalState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = reorderList.removeAt(oldIndex);
                        reorderList.insert(newIndex, item);
                      });
                      IsarService().updateCategorySortOrders(reorderList);
                    },
                    itemBuilder: (context, index) {
                      final cat = reorderList[index];
                      return ListTile(
                        key: ValueKey(cat.id),
                        title: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(
                          Icons.drag_handle_rounded,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      ref.invalidate(watchlistCategoriesProvider);
    });
  }
  void _showCategoryOptions(
    String categoryName,
    List<WatchlistCategory> allCats,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)!.editAssets),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoryAssetsSheet(categoryName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.reorder_rounded, color: Colors.orange),
              title: Text(AppLocalizations.of(context)!.reorderList),
              onTap: () {
                Navigator.pop(context);
                _showReorderCategoriesSheet(allCats);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: Text(
                AppLocalizations.of(context)!.deleteCategory,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await HapticFeedback.heavyImpact();
                await IsarService().deleteCustomCategory(categoryName);
                if (mounted) {
                  setState(() => _activeCategory = 'allCategory');
                  ref.invalidate(watchlistCategoriesProvider);
                  ref.invalidate(cryptoDataProvider);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBubble(
    String categoryKey, {
    bool isCustom = false,
    List<WatchlistCategory>? allCats,
  }) {
    final isActive = _activeCategory == categoryKey;
    final themeColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeCategory = categoryKey);
      },
      onLongPress: isCustom
          ? () {
              HapticFeedback.heavyImpact();
              _showCategoryOptions(categoryKey, allCats ?? []);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getCategoryDisplayName(categoryKey),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? themeColor : Colors.white,
          ),
        ),
      ),
    );
  }
  String _getCategoryDisplayName(String categoryKey) {
    switch (categoryKey) {
      case 'allCategory':
        return AppLocalizations.of(context)!.allCategory;
      case 'cryptoCategory':
        return AppLocalizations.of(context)!.cryptoCategory;
      case 'stocksCategory':
        return AppLocalizations.of(context)!.stocksCategory;
      case 'forexCategory':
        return AppLocalizations.of(context)!.forexCategory;
      default:
        return categoryKey;
    }
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cryptoDataAsync = ref.watch(cryptoDataProvider);
    final categoriesAsync = ref.watch(watchlistCategoriesProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.greeting,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)!.onlineStatus,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
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
                  ],
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildBubble('allCategory'),
                      _buildBubble('cryptoCategory'),
                      _buildBubble('stocksCategory'),
                      _buildBubble('forexCategory'),
                      categoriesAsync.maybeWhen(
                        data: (cats) {
                          final sortedCats = List<WatchlistCategory>.from(
                            cats,
                          )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                          return Row(
                            children: sortedCats
                                .map(
                                  (c) => _buildBubble(
                                    c.name,
                                    isCustom: true,
                                    allCats: sortedCats,
                                  ),
                                )
                                .toList(),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _showAddCategoryDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          OfflineBanner(isOffline: _isOffline),
          Expanded(
            child: cryptoDataAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: 5,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CustomShimmer(height: 100, borderRadius: 24),
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  '${AppLocalizations.of(context)!.failedToLoadData}: $err',
                ),
              ),
              data: (response) {
                final responseOfflineStatus = response['isOffline'] == true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _isOffline != responseOfflineStatus) {
                    setState(() => _isOffline = responseOfflineStatus);
                  }
                });
                final rawData = response['data'];
                final List<AssetCache> incomingData = rawData is List
                    ? rawData.whereType<AssetCache>().toList()
                    : <AssetCache>[];
                _allWatchlistedAssets = incomingData
                    .where((e) => e.isWatchlisted)
                    .toList();
                var filteredAssets = List<AssetCache>.from(
                  _allWatchlistedAssets,
                );
                if (_activeCategory != 'allCategory') {
                  if ([
                    'cryptoCategory',
                    'stocksCategory',
                    'forexCategory',
                  ].contains(_activeCategory)) {
                    final marketType = _activeCategory == 'cryptoCategory'
                        ? 'crypto'
                        : _activeCategory == 'stocksCategory'
                        ? 'stocks'
                        : 'forex';
                    filteredAssets = filteredAssets
                        .where((e) => e.marketType.toLowerCase() == marketType)
                        .toList();
                  } else {
                    filteredAssets = filteredAssets
                        .where(
                          (e) => e.customCategories.contains(_activeCategory),
                        )
                        .toList();
                  }
                }
                filteredAssets.sort(
                  (a, b) => a.sortOrder.compareTo(b.sortOrder),
                );
                if (filteredAssets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        AppLocalizations.of(context)!.emptyCategoryMessage,
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                _localAssets = filteredAssets;
                return ReorderableListView.builder(
                  // FIX: Jarak bawah 120 biar lolos dari BottomNav
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  itemCount: _localAssets.length,
                  proxyDecorator:
                      (Widget child, int index, Animation<double> animation) {
                        return Material(
                          elevation: 8,
                          color: Colors.transparent,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          child: child,
                        );
                      },
                  onReorder: (oldIndex, newIndex) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _localAssets.removeAt(oldIndex);
                      _localAssets.insert(newIndex, item);
                    });
                    _saveSortOrderToIsar(_localAssets);
                  },
                  itemBuilder: (context, index) {
                    final asset = _localAssets[index];
                    return Padding(
                      key: ValueKey(asset.symbol),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () async {
                          await HapticFeedback.heavyImpact();
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AssetDetailScreen(asset: asset),
                              ),
                            );
                          }
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
