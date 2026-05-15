import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/database/asset_cache.dart';
import '../../core/repositories/crypto_repository.dart';
import '../../core/repositories/forex_repository.dart';
import '../../core/repositories/stocks_repository.dart';
import '../../core/services/isar_service.dart';
import '../../core/providers/api_provider.dart';
import '../../shared/widgets/price_alert_bottom_sheet.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';

final Map<String, List<FlSpot>> _chartMemoryCache = {};

class AssetDetailScreen extends ConsumerStatefulWidget {
  final AssetCache asset;
  const AssetDetailScreen({super.key, required this.asset});
  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];
  String _selectedTimeframe = '1D';
  List<FlSpot> _chartData = [];
  bool _isLoadingChart = false;
  String? _chartErrorMessage;
  late bool _isWatchlisted;
  Timer? _debounceTimer;
  final CryptoRepository _cryptoRepository = CryptoRepository();
  final ForexRepository _forexRepository = ForexRepository();
  final StocksRepository _stocksRepository = StocksRepository();
  final ScreenshotController _screenshotController = ScreenshotController();
  final IsarService _isarService = IsarService();

  @override
  void initState() {
    super.initState();
    _isWatchlisted = widget.asset.isWatchlisted;
    _fetchChartData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchChartData() async {
    final cacheKey = '${widget.asset.symbol}_$_selectedTimeframe';
    if (_chartMemoryCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _chartData = _chartMemoryCache[cacheKey]!;
          _isLoadingChart = false;
          _chartErrorMessage = null;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isLoadingChart = true;
        _chartErrorMessage = null;
      });
    }
    try {
      List<List<double>> historicalData = [];
      if (widget.asset.marketType == 'stocks') {
        historicalData = await _stocksRepository.fetchHistoricalData(
          widget.asset.symbol,
          _selectedTimeframe,
          widget.asset.currentPrice,
        );
      } else if (widget.asset.marketType == 'forex') {
        historicalData = await _forexRepository.fetchHistoricalData(
          widget.asset.symbol,
          _selectedTimeframe,
        );
      } else {
        historicalData = await _cryptoRepository.fetchHistoricalData(
          widget.asset.symbol,
          _selectedTimeframe,
        );
      }

      final chartSpots = <FlSpot>[];
      if (historicalData.isNotEmpty) {
        final minTimestamp = historicalData.first[0];
        final maxTimestamp = historicalData.last[0];
        final timeRange = maxTimestamp - minTimestamp;
        for (final dataPoint in historicalData) {
          final timestamp = dataPoint[0];
          final price = dataPoint[1];
          final normalizedX = timeRange > 0
              ? ((timestamp - minTimestamp) / timeRange) * 100
              : 0.0;
          chartSpots.add(FlSpot(normalizedX, price));
        }
      } else {
        throw Exception("No data");
      }

      _chartMemoryCache[cacheKey] = chartSpots;
      if (mounted) {
        setState(() {
          _chartData = chartSpots;
          _isLoadingChart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chartErrorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingChart = false;
        });
      }
    }
  }

  Future<void> _takeScreenshotAndShare() async {
    try {
      await HapticFeedback.heavyImpact();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.preparingImage),
          duration: const Duration(seconds: 1),
        ),
      );
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await _screenshotController.captureAndSave(
        directory.path,
        fileName: 'tideview_share_${widget.asset.symbol}.png',
        pixelRatio: 2.0,
      );
      if (imagePath != null && mounted) {
        final rate = ref.read(exchangeRateProvider).valueOrNull ?? 1.0;
        final baseCurrency =
            ref.read(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
        final priceStr = CurrencyFormatter.format(
          widget.asset.currentPrice,
          baseCurrency,
          rate,
        );
        await Share.shareXFiles([
          XFile(imagePath),
        ], text: l10n.shareMessage(widget.asset.name, priceStr));
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shareFailed(e.toString()))));
    }
  }

  Future<void> _toggleWatchlist() async {
    await HapticFeedback.selectionClick();
    await _isarService.toggleWatchlist(widget.asset.symbol);
    setState(() => _isWatchlisted = !_isWatchlisted);
    ref.invalidate(cryptoDataProvider);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isWatchlisted ? l10n.addedToWatchlist : l10n.removedFromWatchlist,
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _vibrateSelection() async => await HapticFeedback.selectionClick();

  Widget _buildChartWidget(double rate, String baseCurrency) {
    final l10n = AppLocalizations.of(context)!;
    final isPositive = widget.asset.priceChange24h >= 0;
    final chartColor = isPositive ? Colors.green : Colors.redAccent;

    if (_isLoadingChart) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chartErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.show_chart_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.chartResting,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _chartErrorMessage == 'No data'
                    ? l10n.noChartData
                    : _chartErrorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchChartData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      );
    }

    if (_chartData.isEmpty) {
      return Center(
        child: Text(
          l10n.noChartData,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.grey.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      dashArray: [3, 3],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: chartColor,
                          strokeWidth: 2,
                          strokeColor: Theme.of(context).colorScheme.surface,
                        );
                      },
                    ),
                  );
                }).toList();
              },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final tooltipPrice = CurrencyFormatter.format(
                  touchedSpot.y,
                  baseCurrency,
                  rate,
                );
                return LineTooltipItem(
                  tooltipPrice,
                  TextStyle(
                    color: chartColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _chartData,
            isCurved: true,
            curveSmoothness: 0.25,
            color: chartColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  chartColor.withValues(alpha: 0.3),
                  chartColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPositive = widget.asset.priceChange24h >= 0;
    final chartColor = isPositive ? Colors.green : Colors.redAccent;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
    final formattedPrice = CurrencyFormatter.format(
      widget.asset.currentPrice,
      baseCurrency,
      rate,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                widget.asset.symbol[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.asset.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    widget.asset.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) =>
                    PriceAlertBottomSheet(initialAsset: widget.asset),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isWatchlisted ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isWatchlisted
                  ? Colors.amber
                  : Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _toggleWatchlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  children: [
                    _AssetDetailHeader(
                      formattedPrice: formattedPrice,
                      changeText:
                          '${isPositive ? '+' : ''}${widget.asset.priceChange24h.toStringAsFixed(2)}% ($_selectedTimeframe)',
                      chartColor: chartColor,
                    ),
                    const SizedBox(height: 32),
                    _AssetDetailChartSection(
                      chartWidget: _buildChartWidget(rate, baseCurrency),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AssetDetailTimeframeSelector(
              timeframes: _timeframes,
              selectedTimeframe: _selectedTimeframe,
              onTimeframeSelected: (tf) {
                _vibrateSelection();
                setState(() {
                  _selectedTimeframe = tf;
                  final cacheKey = '${widget.asset.symbol}_$tf';
                  if (!_chartMemoryCache.containsKey(cacheKey)) {
                    _isLoadingChart = true;
                  }
                });
                final cacheKey = '${widget.asset.symbol}_$tf';
                if (_chartMemoryCache.containsKey(cacheKey)) {
                  _fetchChartData();
                  return;
                }
                if (_debounceTimer?.isActive ?? false) {
                  _debounceTimer!.cancel();
                }
                _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
                  _fetchChartData();
                });
              },
            ),
            const SizedBox(height: 32),
            _AssetDetailStatsCard(
              marketStatsLabel: l10n.marketStats,
              marketTypeLabel: l10n.marketType,
              marketTypeValue: widget.asset.marketType.toUpperCase(),
              lastUpdatedLabel: l10n.lastUpdated,
              lastUpdatedValue:
                  '${widget.asset.lastUpdated.hour}:${widget.asset.lastUpdated.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 32),
            _buildShareButton(l10n.shareCard),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _takeScreenshotAndShare,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetDetailHeader extends StatelessWidget {
  final String formattedPrice;
  final String changeText;
  final Color chartColor;

  const _AssetDetailHeader({
    required this.formattedPrice,
    required this.changeText,
    required this.chartColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          formattedPrice,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          changeText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: chartColor,
          ),
        ),
      ],
    );
  }
}

class _AssetDetailChartSection extends StatelessWidget {
  final Widget chartWidget;

  const _AssetDetailChartSection({required this.chartWidget});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 250, width: double.infinity, child: chartWidget);
  }
}

class _AssetDetailTimeframeSelector extends StatelessWidget {
  final List<String> timeframes;
  final String selectedTimeframe;
  final void Function(String) onTimeframeSelected;

  const _AssetDetailTimeframeSelector({
    required this.timeframes,
    required this.selectedTimeframe,
    required this.onTimeframeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: timeframes.map((tf) {
          final isSelected = selectedTimeframe == tf;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTimeframeSelected(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tf,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AssetDetailStatsCard extends StatelessWidget {
  final String marketStatsLabel;
  final String marketTypeLabel;
  final String marketTypeValue;
  final String lastUpdatedLabel;
  final String lastUpdatedValue;

  const _AssetDetailStatsCard({
    required this.marketStatsLabel,
    required this.marketTypeLabel,
    required this.marketTypeValue,
    required this.lastUpdatedLabel,
    required this.lastUpdatedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marketStatsLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _StatRow(label: marketTypeLabel, value: marketTypeValue),
          const Divider(height: 24),
          _StatRow(label: lastUpdatedLabel, value: lastUpdatedValue),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
