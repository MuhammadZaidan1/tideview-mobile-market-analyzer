import 'package:isar/isar.dart';

part 'price_alert.g.dart';

@collection
class PriceAlert {
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value)
  late String symbol;
  late double targetPrice;
  late bool isAbove;
  bool isActive = true;
}
