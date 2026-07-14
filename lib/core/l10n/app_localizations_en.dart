// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get markets => 'Markets';

  @override
  String get convert => 'Convert';

  @override
  String get settings => 'Settings';

  @override
  String get emptyCategoryMessage =>
      'Category is empty. Add assets from Markets.';

  @override
  String get greeting => 'TideView';

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
  String get exploreMarkets => 'Explore Markets';

  @override
  String get searchAssets => 'Search assets...';

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
  String get systemDefault => 'Default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get selectThemeColor => 'Choose theme color';

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
  String get cacheSuccess => 'Cache cleared successfully.';

  @override
  String get preparingImage => 'Preparing image...';

  @override
  String shareMessage(String name, String price) {
    return 'Monitoring $name price on TideView.\nCurrent price is $price.';
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
  String get chartResting => 'Chart is idle';

  @override
  String get noChartData => 'No chart data available';

  @override
  String get tryAgain => 'Try again';

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
  String get assetNotFound => 'Asset not found.';

  @override
  String get offlineModeMessage => 'Offline mode — showing cached data';

  @override
  String get setPriceAlert => 'Set price alert';

  @override
  String get priceAlertDescription =>
      'Receive a notification when price reaches target.';

  @override
  String get selectAssetLabel => 'Select asset';

  @override
  String get chooseAssetHint => 'Choose asset...';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get priceGoesAbove => 'Goes above';

  @override
  String get priceGoesBelow => 'Goes below';

  @override
  String get alertSavedSuccess => 'Alert saved';

  @override
  String get setAlarmButton => 'Set alert';

  @override
  String get widgetSyncRate => 'Widget sync rate';

  @override
  String get sync15Min => '15 min';

  @override
  String get sync30Min => '30 min';

  @override
  String get sync1Hour => '1 hour';

  @override
  String get widgetManagement => 'Widget Management';

  @override
  String get selectedAsset => 'Selected Asset';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageAlerts => 'Manage alerts';

  @override
  String get noAlertsSet => 'No alerts set';

  @override
  String get priceAbove => 'Above';

  @override
  String get priceBelow => 'Below';

  @override
  String get addAlert => 'Add alert';

  @override
  String get clearCacheConfirmTitle => 'Clear cache?';

  @override
  String get clearCacheConfirmMessage =>
      'Delete all cached data?\nThis cannot be undone.';

  @override
  String get yesClear => 'Yes, clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get categoryExample => 'e.g., Tech Stocks, Top Crypto...';

  @override
  String get save => 'Save';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get emptyWatchlistMessage => 'Watchlist is empty. Add assets first.';

  @override
  String get editAssets => 'Edit Assets';

  @override
  String get reorderList => 'Reorder List';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get categoryCreatedTitle => 'Success';

  @override
  String get categoryCreatedMessage => 'Category created successfully.';

  @override
  String get deleteCategoryConfirmTitle => 'Delete Category?';

  @override
  String get deleteCategoryConfirmMessage =>
      'Are you sure you want to delete this category? Assets inside will remain safe.';

  @override
  String get yesDelete => 'Yes, delete';

  @override
  String get forexIntradayNotAvailable =>
      'Intraday (1D) data is not available for Forex markets.';

  @override
  String get welcomeTitle => 'Welcome to TideView';

  @override
  String get welcomeSubtitle => 'Track crypto, stocks, and forex in real-time';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithGithub => 'Continue with GitHub';

  @override
  String get loginTitle => 'Log in first';

  @override
  String get loginSubtitle => 'To sync your watchlist & alerts across devices';

  @override
  String get manageAccount => 'Manage Account';

  @override
  String get loggedInAs => 'Logged in as';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get notLoggedInSubtitle => 'Watchlist & alert sync is not active';

  @override
  String get tapToLogin => 'Tap to log in';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutConfirmTitle => 'Log out?';

  @override
  String get logOutConfirmMessage =>
      'You will switch back to guest mode. Your local data will remain on this device.';

  @override
  String get yesLogOut => 'Yes, log out';

  @override
  String get loginFailed => 'Login failed';
}
