import 'package:flutter/material.dart';
import '../shared/widgets/main_layout.dart';
import '../features/asset_detail/asset_detail_screen.dart';
import 'database/asset_cache.dart';

class AppRoutes {
  static const String home = '/';
  static const String assetDetail = '/asset_detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainLayout());

      case assetDetail:
        final asset = settings.arguments as AssetCache;
        return MaterialPageRoute(
          builder: (_) => AssetDetailScreen(asset: asset),
        );

      default:
        return MaterialPageRoute(builder: (_) => const MainLayout());
    }
  }
}
