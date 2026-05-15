import 'package:isar/isar.dart';

part 'chart_cache.g.dart';

@collection
class ChartCache {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String cacheKey; 
  late String pricesJson; 
  late DateTime lastUpdated;
}
