import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart'; 

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.grid_view_rounded, 'label': l10n.dashboard},
      {'icon': Icons.analytics_rounded, 'label': l10n.markets},
      {'icon': Icons.swap_horiz_rounded, 'label': l10n.convert},
      {'icon': Icons.settings_suggest_rounded, 'label': l10n.settings},
    ];
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        height: 65,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final color = isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.5);
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[index]['icon'], color: color, size: 26),
                    const SizedBox(height: 4),
                    if (isSelected)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
