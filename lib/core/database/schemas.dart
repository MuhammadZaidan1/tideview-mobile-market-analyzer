import 'package:isar/isar.dart';

import 'asset_cache.dart';
import 'user_prefs.dart';
import 'price_alert.dart';
import 'chart_cache.dart';
import 'watchlist_category.dart';

final List<CollectionSchema<dynamic>> appSchemas = [
  AssetCacheSchema,
  UserPrefsSchema,
  PriceAlertSchema,
  ChartCacheSchema,
  WatchlistCategorySchema,
];
