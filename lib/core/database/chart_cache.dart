import 'package:isar/isar.dart';

part 'chart_cache.g.dart';

@collection
class ChartCache {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String cacheKey; // Format: "symbol_days" contoh: "bitcoin_7"
  late String pricesJson; // Data harga kita ubah jadi string JSON
  late DateTime lastUpdated;
}
