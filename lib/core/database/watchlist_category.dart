import 'package:isar/isar.dart';

part 'watchlist_category.g.dart';

@collection
class WatchlistCategory {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String name;
  int sortOrder = 0;
}
