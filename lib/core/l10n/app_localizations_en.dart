// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TideView';

  @override
  String get welcome => 'Welcome back';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get markets => 'Markets';

  @override
  String get convert => 'Convert';

  @override
  String get settings => 'Settings';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get categoryExample => 'Example: Galau Coins, Long Term';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get emptyWatchlistMessage =>
      'Main watchlist is still empty.\nAdd coins from Market first!';

  @override
  String get editAssets => 'Edit Assets';

  @override
  String get reorderList => 'Reorder List';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get greeting => 'Hello, Zaidan!';

  @override
  String get onlineStatus => 'Online';

  @override
  String get allCategory => 'All';

  @override
  String get cryptoCategory => 'Crypto';

  @override
  String get stocksCategory => 'Stocks';

  @override
  String get forexCategory => 'Forex';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get emptyCategoryMessage =>
      'Watchlist is empty in this category.\nSearch and add favorites from the Markets menu.';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortByName => 'Name (A - Z)';

  @override
  String get topGainers => 'Top Gainers (🔥)';

  @override
  String get topLosers => 'Top Losers (🩸)';

  @override
  String get marketExplorers => 'Market Explorers';

  @override
  String get searchAssets => 'Search assets...';

  @override
  String get error => 'Error';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get select => 'Select';

  @override
  String get calculator => 'Calculator';

  @override
  String get marketSnapshot => 'Market Snapshot';

  @override
  String get appearance => 'Appearance';

  @override
  String get appTheme => 'App Theme';

  @override
  String get systemDefault => 'System Default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get selectThemeColor => 'Select Theme Color';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get baseCurrency => 'Base Currency';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheSubtitle => 'Free up storage space';

  @override
  String get cacheSuccess => 'Cache cleared successfully! 🚀';

  @override
  String get preparingImage => 'Preparing image...';

  @override
  String shareMessage(String name, String price) {
    return 'Currently monitoring $name price on TideView! It\'s currently \$$price. What do you think?';
  }

  @override
  String shareFailed(String error) {
    return 'Failed to share image: $error';
  }

  @override
  String get addedToWatchlist => 'Added to Watchlist';

  @override
  String get removedFromWatchlist => 'Removed from Watchlist';

  @override
  String get chartResting => 'Chart is Resting';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noChartData => 'No chart data available';

  @override
  String get marketStats => 'Market Stats';

  @override
  String get marketType => 'Market Type';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get shareCard => 'Share Card';

  @override
  String get selectAsset => 'Select Asset';

  @override
  String get searchAssetHint => 'Search assets (BTC, Apple, USD)...';

  @override
  String get assetNotFound => 'Asset not found.';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get offlineModeMessage => 'Offline Mode - Showing cached data';

  @override
  String get setPriceAlert => 'Set Price Alert';

  @override
  String get priceAlertDescription =>
      'Receive a push notification when the price hits your target.';

  @override
  String get selectAssetLabel => 'SELECT ASSET';

  @override
  String get chooseAssetHint => 'Choose Asset...';

  @override
  String get conditionLabel => 'CONDITION';

  @override
  String get priceGoesAbove => 'Price goes ABOVE';

  @override
  String get priceGoesBelow => 'Price goes BELOW';

  @override
  String get targetPriceUsd => 'TARGET PRICE (USD)';

  @override
  String get alertSavedSuccess => 'Alert saved successfully!';

  @override
  String get setAlarmButton => 'Set Alarm';

  @override
  String get widgetSyncRate => 'Widget Sync Rate';

  @override
  String get sync15Min => '15 Minutes';

  @override
  String get sync30Min => '30 Minutes';

  @override
  String get sync1Hour => '1 Hour';

  @override
  String get widgetManagement => 'Widget Management';

  @override
  String get selectedAsset => 'Selected Asset';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageAlerts => 'Manage Price Alerts';

  @override
  String get noAlerts => 'No alerts set';

  @override
  String get priceAbove => 'Above';

  @override
  String get priceBelow => 'Below';

  @override
  String get alertDeleted => 'Alert deleted';

  @override
  String get exploreMarkets => 'Explore Markets';
}
