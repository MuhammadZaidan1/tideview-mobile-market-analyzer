import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart'; 

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  const OfflineBanner({super.key, required this.isOffline});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: isOffline ? 36.0 : 0.0,
      width: double.infinity,
      color: Colors.orange.shade800,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: 36.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                l10n.offlineModeMessage, 
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
