import 'package:flutter/material.dart';
import 'custom_popup.dart';

class FavoriteButton extends StatefulWidget {
  final bool initialValue;
  final String successMessage;
  final String? removedMessage;
  final String errorMessage;
  final Future<void> Function(bool nextValue) onToggle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  const FavoriteButton({
    super.key,
    required this.initialValue,
    required this.successMessage,
    this.removedMessage,
    required this.errorMessage,
    required this.onToggle,
    this.activeColor,
    this.inactiveColor,
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
    this.enabled = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;
  bool _isPending = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _isFavorite = widget.initialValue;
      });
    }
  }

  Future<void> _handleTap() async {
    if (_isPending || !widget.enabled) return;

    final previousValue = _isFavorite;
    final nextValue = !previousValue;

    setState(() {
      _isFavorite = nextValue;
      _isPending = true;
    });

    try {
      await widget.onToggle(nextValue);
      if (!mounted) return;

      CustomPopup.showSnackBar(
        context,
        message: nextValue
            ? widget.successMessage
            : widget.removedMessage ?? widget.successMessage,
        type: PopupType.success,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isFavorite = previousValue;
      });
      CustomPopup.showSnackBar(
        context,
        message: widget.errorMessage,
        type: PopupType.caution,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.amber;
    final inactiveColor =
        widget.inactiveColor ?? Theme.of(context).colorScheme.onSurface;

    return IconButton(
      padding: widget.padding,
      constraints: const BoxConstraints(),
      onPressed: _isPending || !widget.enabled ? null : _handleTap,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          key: ValueKey(_isFavorite),
          _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
          size: widget.size,
          color: _isFavorite ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
