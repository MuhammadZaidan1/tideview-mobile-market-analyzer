import 'package:isar/isar.dart';

part 'asset_cache.g.dart';

@collection
class AssetCache {
  Id get id => Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String symbol;
  late String name;
  late double currentPrice;
  late double priceChange24h;
  late DateTime lastUpdated;
  late String marketType;
  bool isWatchlisted = false;
  String? historicalDataJson;
  int sortOrder = 0;
  List<String> customCategories = [];
}
