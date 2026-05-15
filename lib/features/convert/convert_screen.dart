import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/database/asset_cache.dart';
import '../../shared/screens/asset_selector_screen.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/providers/exchange_rate_provider.dart';
import '../../core/theme/theme_provider.dart';

class ConvertScreen extends ConsumerStatefulWidget {
  const ConvertScreen({super.key});
  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _amountController = TextEditingController();
  AssetCache? _fromAsset;
  AssetCache? _toAsset;
  double _convertedResult = 0.0;
  double _exchangeRate = 0.0;
  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateConversion);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    final fromAsset = _fromAsset;
    final toAsset = _toAsset;
    if (fromAsset == null || toAsset == null) {
      if (mounted) {
        setState(() {
          _convertedResult = 0.0;
          _exchangeRate = 0.0;
        });
      }
      return;
    }
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0.0;
    final rate = fromAsset.currentPrice / toAsset.currentPrice;
    if (mounted) {
      setState(() {
        _exchangeRate = rate;
        _convertedResult = amount * rate;
      });
    }
  }

  void _swapAssets() {
    HapticFeedback.mediumImpact();
    setState(() {
      final temp = _fromAsset;
      _fromAsset = _toAsset;
      _toAsset = temp;
    });
    _calculateConversion();
  }

  Future<void> _selectAsset(bool isFrom) async {
    HapticFeedback.selectionClick();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AssetSelectorScreen(),
        fullscreenDialog: true,
      ),
    );
    if (result != null && result is AssetCache) {
      setState(() {
        if (isFrom) {
          _fromAsset = result;
          if (_fromAsset?.symbol == _toAsset?.symbol) _toAsset = null;
        } else {
          _toAsset = result;
          if (_toAsset?.symbol == _fromAsset?.symbol) _fromAsset = null;
        }
      });
      _calculateConversion();
    }
  }

  Widget _buildAssetSnapshot(AssetCache asset) {
    final isPositive = asset.priceChange24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.redAccent;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final rate = ref.watch(exchangeRateProvider).valueOrNull ?? 1.0;
    final baseCurrency =
        ref.watch(themeProvider).valueOrNull?.baseCurrency ?? 'USD';
    final formattedPrice = CurrencyFormatter.format(
      asset.currentPrice,
      baseCurrency,
      rate,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Text(
              asset.symbol[0],
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  asset.symbol,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${asset.priceChange24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    ref.watch(cryptoDataProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.calculator,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      _ConvertAssetCard(
                        isFrom: true,
                        asset: _fromAsset,
                        amountController: _amountController,
                        convertedResult: _convertedResult,
                        onSelect: () => _selectAsset(true),
                      ),
                      const SizedBox(height: 8),
                      _ConvertAssetCard(
                        isFrom: false,
                        asset: _toAsset,
                        amountController: null,
                        convertedResult: _convertedResult,
                        onSelect: () => _selectAsset(false),
                      ),
                    ],
                  ),
                  _ConvertSwapButton(
                    primaryColor: primaryColor,
                    onPressed: _swapAssets,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_fromAsset != null && _toAsset != null) ...[
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '1 ${_fromAsset!.symbol} = ${_exchangeRate.toStringAsFixed(4)} ${_toAsset!.symbol}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.marketSnapshot,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAssetSnapshot(_fromAsset!),
                _buildAssetSnapshot(_toAsset!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConvertAssetCard extends StatelessWidget {
  final bool isFrom;
  final AssetCache? asset;
  final TextEditingController? amountController;
  final double convertedResult;
  final VoidCallback onSelect;

  const _ConvertAssetCard({
    required this.isFrom,
    required this.asset,
    required this.amountController,
    required this.convertedResult,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFrom ? l10n.from : l10n.to,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onSelect,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (asset != null) ...[
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            asset!.symbol[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          asset!.symbol,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.select,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isFrom
                    ? TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          convertedResult.toStringAsFixed(
                            convertedResult < 1 && convertedResult > 0 ? 6 : 2,
                          ),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: asset == null
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (asset != null) ...[
            const SizedBox(height: 12),
            Text(
              asset!.name,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConvertSwapButton extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onPressed;

  const _ConvertSwapButton({
    required this.primaryColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.swap_vert_rounded, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
