import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(
    double usdPrice,
    String targetCurrency,
    double exchangeRate,
  ) {
    final localPrice = usdPrice * exchangeRate;
    switch (targetCurrency) {
      case 'IDR':
        final format = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );
        return format.format(localPrice);
      case 'EUR':
        final format = NumberFormat.currency(
          locale: 'de_DE',
          symbol: '€',
          decimalDigits: 2,
        );
        return format.format(localPrice);
      case 'GBP':
        final format = NumberFormat.currency(
          locale: 'en_GB',
          symbol: '£',
          decimalDigits: 2,
        );
        return format.format(localPrice);
      case 'USD':
      default:
        final decimalPlaces = localPrice < 1.0 && localPrice > 0 ? 4 : 2;
        final format = NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: decimalPlaces,
        );
        return format.format(localPrice);
    }
  }
  static double toUSD(double localInputPrice, double exchangeRate) {
    if (exchangeRate <= 0) return localInputPrice; 
    return localInputPrice / exchangeRate;
  }
}
