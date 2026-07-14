import 'package:flutter/material.dart';

enum PopupType { success, alert, caution }

class CustomPopup extends StatelessWidget {
  final String title;
  final String message;
  final PopupType type;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;

  static void showSnackBar(
    BuildContext context, {
    required String message,
    PopupType type = PopupType.alert,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: _colorForType(type),
        content: Row(
          children: [
            Icon(_iconForType(type), color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    Widget? child,
    String? title,
    String? message,
    PopupType type = PopupType.alert,
    String confirmLabel = 'OK',
    String? cancelLabel,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        if (child != null) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _colorForType(type).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(type),
                    color: _colorForType(type),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    if (cancelLabel != null) ...[
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(cancelLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            onConfirm ?? () => Navigator.pop(dialogContext),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _colorForType(PopupType type) {
    switch (type) {
      case PopupType.success:
        return Colors.green.shade600;
      case PopupType.alert:
        return Colors.amber.shade700;
      case PopupType.caution:
        return Colors.red.shade600;
    }
  }

  static IconData _iconForType(PopupType type) {
    switch (type) {
      case PopupType.success:
        return Icons.check_circle_rounded;
      case PopupType.alert:
        return Icons.info_rounded;
      case PopupType.caution:
        return Icons.warning_rounded;
    }
  }

  const CustomPopup({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.confirmLabel,
    this.cancelLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    IconData iconData;

    switch (type) {
      case PopupType.success:
        primaryColor = Colors.green.shade600;
        iconData = Icons.check_circle_rounded;
        break;
      case PopupType.alert:
        primaryColor = Colors.amber.shade600;
        iconData = Icons.info_rounded;
        break;
      case PopupType.caution:
        primaryColor = Colors.red.shade600;
        iconData = Icons.warning_rounded;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: primaryColor, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelLabel!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
