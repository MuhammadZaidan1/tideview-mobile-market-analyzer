import 'package:isar/isar.dart';

part 'user_prefs.g.dart';

@collection
class UserPrefs {
  Id id = 1;
  late String activeThemeHex;
  late bool isDarkMode;
  late String languageCode;
  late String baseCurrency;
  DateTime? lastCryptoSyncTime;
  int syncIntervalMinutes = 15;
  String widgetAssetSymbol = 'BTC'; 
  double exchangeRate = 1.0; 
}