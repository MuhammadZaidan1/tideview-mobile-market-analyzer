import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TideView'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Category'**
  String get createNewCategory;

  /// No description provided for @categoryExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Galau Coins, Long Term'**
  String get categoryExample;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @emptyWatchlistMessage.
  ///
  /// In en, this message translates to:
  /// **'Main watchlist is still empty.\nAdd coins from Market first!'**
  String get emptyWatchlistMessage;

  /// No description provided for @editAssets.
  ///
  /// In en, this message translates to:
  /// **'Edit Assets'**
  String get editAssets;

  /// No description provided for @reorderList.
  ///
  /// In en, this message translates to:
  /// **'Reorder List'**
  String get reorderList;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, Zaidan!'**
  String get greeting;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatus;

  /// No description provided for @allCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategory;

  /// No description provided for @cryptoCategory.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get cryptoCategory;

  /// No description provided for @stocksCategory.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stocksCategory;

  /// No description provided for @forexCategory.
  ///
  /// In en, this message translates to:
  /// **'Forex'**
  String get forexCategory;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// No description provided for @emptyCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Watchlist is empty in this category.\nSearch and add favorites from the Markets menu.'**
  String get emptyCategoryMessage;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name (A - Z)'**
  String get sortByName;

  /// No description provided for @topGainers.
  ///
  /// In en, this message translates to:
  /// **'Top Gainers (🔥)'**
  String get topGainers;

  /// No description provided for @topLosers.
  ///
  /// In en, this message translates to:
  /// **'Top Losers (🩸)'**
  String get topLosers;

  /// No description provided for @marketExplorers.
  ///
  /// In en, this message translates to:
  /// **'Market Explorers'**
  String get marketExplorers;

  /// No description provided for @searchAssets.
  ///
  /// In en, this message translates to:
  /// **'Search assets...'**
  String get searchAssets;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @marketSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Market Snapshot'**
  String get marketSnapshot;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @selectThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Select Theme Color'**
  String get selectThemeColor;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base Currency'**
  String get baseCurrency;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @cacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get cacheSubtitle;

  /// No description provided for @cacheSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully! 🚀'**
  String get cacheSuccess;

  /// No description provided for @preparingImage.
  ///
  /// In en, this message translates to:
  /// **'Preparing image...'**
  String get preparingImage;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Currently monitoring {name} price on TideView! It\'s currently \${price}. What do you think?'**
  String shareMessage(String name, String price);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share image: {error}'**
  String shareFailed(String error);

  /// No description provided for @addedToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Added to Watchlist'**
  String get addedToWatchlist;

  /// No description provided for @removedFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from Watchlist'**
  String get removedFromWatchlist;

  /// No description provided for @chartResting.
  ///
  /// In en, this message translates to:
  /// **'Chart is Resting'**
  String get chartResting;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noChartData.
  ///
  /// In en, this message translates to:
  /// **'No chart data available'**
  String get noChartData;

  /// No description provided for @marketStats.
  ///
  /// In en, this message translates to:
  /// **'Market Stats'**
  String get marketStats;

  /// No description provided for @marketType.
  ///
  /// In en, this message translates to:
  /// **'Market Type'**
  String get marketType;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'Share Card'**
  String get shareCard;

  /// No description provided for @selectAsset.
  ///
  /// In en, this message translates to:
  /// **'Select Asset'**
  String get selectAsset;

  /// No description provided for @searchAssetHint.
  ///
  /// In en, this message translates to:
  /// **'Search assets (BTC, Apple, USD)...'**
  String get searchAssetHint;

  /// No description provided for @assetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Asset not found.'**
  String get assetNotFound;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @offlineModeMessage.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode - Showing cached data'**
  String get offlineModeMessage;

  /// No description provided for @setPriceAlert.
  ///
  /// In en, this message translates to:
  /// **'Set Price Alert'**
  String get setPriceAlert;

  /// No description provided for @priceAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive a push notification when the price hits your target.'**
  String get priceAlertDescription;

  /// No description provided for @selectAssetLabel.
  ///
  /// In en, this message translates to:
  /// **'SELECT ASSET'**
  String get selectAssetLabel;

  /// No description provided for @chooseAssetHint.
  ///
  /// In en, this message translates to:
  /// **'Choose Asset...'**
  String get chooseAssetHint;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'CONDITION'**
  String get conditionLabel;

  /// No description provided for @priceGoesAbove.
  ///
  /// In en, this message translates to:
  /// **'Price goes ABOVE'**
  String get priceGoesAbove;

  /// No description provided for @priceGoesBelow.
  ///
  /// In en, this message translates to:
  /// **'Price goes BELOW'**
  String get priceGoesBelow;

  /// No description provided for @targetPriceUsd.
  ///
  /// In en, this message translates to:
  /// **'TARGET PRICE (USD)'**
  String get targetPriceUsd;

  /// No description provided for @alertSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Alert saved successfully!'**
  String get alertSavedSuccess;

  /// No description provided for @setAlarmButton.
  ///
  /// In en, this message translates to:
  /// **'Set Alarm'**
  String get setAlarmButton;

  /// No description provided for @widgetSyncRate.
  ///
  /// In en, this message translates to:
  /// **'Widget Sync Rate'**
  String get widgetSyncRate;

  /// No description provided for @sync15Min.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get sync15Min;

  /// No description provided for @sync30Min.
  ///
  /// In en, this message translates to:
  /// **'30 Minutes'**
  String get sync30Min;

  /// No description provided for @sync1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour'**
  String get sync1Hour;

  /// No description provided for @widgetManagement.
  ///
  /// In en, this message translates to:
  /// **'Widget Management'**
  String get widgetManagement;

  /// No description provided for @selectedAsset.
  ///
  /// In en, this message translates to:
  /// **'Selected Asset'**
  String get selectedAsset;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage Price Alerts'**
  String get manageAlerts;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts set'**
  String get noAlerts;

  /// No description provided for @priceAbove.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get priceAbove;

  /// No description provided for @priceBelow.
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get priceBelow;

  /// No description provided for @alertDeleted.
  ///
  /// In en, this message translates to:
  /// **'Alert deleted'**
  String get alertDeleted;

  /// No description provided for @exploreMarkets.
  ///
  /// In en, this message translates to:
  /// **'Explore Markets'**
  String get exploreMarkets;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
