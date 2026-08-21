import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search Your Book...'**
  String get searchPlaceholder;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points: {count}'**
  String points(Object count);

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get mostPopular;

  /// No description provided for @bookCategories.
  ///
  /// In en, this message translates to:
  /// **'Book categories'**
  String get bookCategories;

  /// No description provided for @philosophy.
  ///
  /// In en, this message translates to:
  /// **'Philosophy'**
  String get philosophy;

  /// No description provided for @literatureAndNovels.
  ///
  /// In en, this message translates to:
  /// **'Literature & Novels'**
  String get literatureAndNovels;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @selfDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Self-development'**
  String get selfDevelopment;

  /// No description provided for @borrowingRecord.
  ///
  /// In en, this message translates to:
  /// **'Borrowing Record'**
  String get borrowingRecord;

  /// No description provided for @myOrdersAndDelivery.
  ///
  /// In en, this message translates to:
  /// **'My Orders & Delivery'**
  String get myOrdersAndDelivery;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @buyingTab.
  ///
  /// In en, this message translates to:
  /// **'Buying'**
  String get buyingTab;

  /// No description provided for @borrowingTab.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get borrowingTab;

  /// The borrow fee of the book
  ///
  /// In en, this message translates to:
  /// **'Borrow Fee: {price} SYP'**
  String borrowPrice(String price);

  /// No description provided for @buyPrice.
  ///
  /// In en, this message translates to:
  /// **'Buying price: {price} SYP'**
  String buyPrice(Object price);

  /// No description provided for @confirmOrderAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order & Pay'**
  String get confirmOrderAndPay;

  /// No description provided for @checkoutAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Checkout & Payment'**
  String get checkoutAndPayment;

  /// No description provided for @invoiceSummary.
  ///
  /// In en, this message translates to:
  /// **'Invoice Summary'**
  String get invoiceSummary;

  /// No description provided for @buyingBooks.
  ///
  /// In en, this message translates to:
  /// **'Books for Purchase'**
  String get buyingBooks;

  /// No description provided for @borrowingBooks.
  ///
  /// In en, this message translates to:
  /// **'Books for Borrowing'**
  String get borrowingBooks;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String itemsCount(Object count);

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currency;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @detailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address'**
  String get detailedAddress;

  /// No description provided for @deliveryService.
  ///
  /// In en, this message translates to:
  /// **'Delivery Service'**
  String get deliveryService;

  /// No description provided for @yesDelivery.
  ///
  /// In en, this message translates to:
  /// **'Yes, I want delivery'**
  String get yesDelivery;

  /// No description provided for @noDelivery.
  ///
  /// In en, this message translates to:
  /// **'No, I will pick it up'**
  String get noDelivery;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card / Electronic Payment'**
  String get creditCard;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @borrowingTerms.
  ///
  /// In en, this message translates to:
  /// **'Borrowing Terms & Notes'**
  String get borrowingTerms;

  /// No description provided for @importantNoteBorrow.
  ///
  /// In en, this message translates to:
  /// **'Important Note for Borrowed Books'**
  String get importantNoteBorrow;

  /// No description provided for @borrowPeriodNotice.
  ///
  /// In en, this message translates to:
  /// **'The maximum borrowing period is 7 days. Please return the books on time to avoid fines.'**
  String get borrowPeriodNotice;

  /// No description provided for @confirmOrderNow.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order Now'**
  String get confirmOrderNow;

  /// No description provided for @orderReceived.
  ///
  /// In en, this message translates to:
  /// **'Order Received Successfully!'**
  String get orderReceived;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String orderDate(Object date);

  /// No description provided for @deliveryRequested.
  ///
  /// In en, this message translates to:
  /// **'Delivery: Requested'**
  String get deliveryRequested;

  /// No description provided for @deliveryNotRequested.
  ///
  /// In en, this message translates to:
  /// **'Delivery: Self Pickup'**
  String get deliveryNotRequested;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @booksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} books'**
  String booksCount(Object count);

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sortPrice;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @favouritePage.
  ///
  /// In en, this message translates to:
  /// **'Favourite Page'**
  String get favouritePage;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'OrderHistory'**
  String get orderHistory;

  /// No description provided for @myPoints.
  ///
  /// In en, this message translates to:
  /// **'My Points: {points}'**
  String myPoints(int points);

  /// No description provided for @bookGhadrAlSalafiya.
  ///
  /// In en, this message translates to:
  /// **'Ghadr Al-Salafiya'**
  String get bookGhadrAlSalafiya;

  /// No description provided for @authorEzzElDin.
  ///
  /// In en, this message translates to:
  /// **'Ezz El-Din'**
  String get authorEzzElDin;

  /// No description provided for @bookAncientLibrary.
  ///
  /// In en, this message translates to:
  /// **'Novel:\nThe Ancient Library'**
  String get bookAncientLibrary;

  /// No description provided for @authorGarmoush.
  ///
  /// In en, this message translates to:
  /// **'Garmoush'**
  String get authorGarmoush;

  /// No description provided for @bookTheSpider.
  ///
  /// In en, this message translates to:
  /// **'The Spider'**
  String get bookTheSpider;

  /// No description provided for @authorDawnWizard.
  ///
  /// In en, this message translates to:
  /// **'Dawn Wizard'**
  String get authorDawnWizard;

  /// No description provided for @searchYourBook.
  ///
  /// In en, this message translates to:
  /// **'Search your book'**
  String get searchYourBook;

  /// No description provided for @noItemsInSection.
  ///
  /// In en, this message translates to:
  /// **'NoItemsInSection'**
  String get noItemsInSection;

  /// The purchase price of the book
  ///
  /// In en, this message translates to:
  /// **'Purchase Price: {price} SYP'**
  String purchasePrice(String price);

  /// No description provided for @yesWantsDelivery.
  ///
  /// In en, this message translates to:
  /// **'Yes, I want home delivery'**
  String get yesWantsDelivery;

  /// No description provided for @noStorePickup.
  ///
  /// In en, this message translates to:
  /// **'No, I will pick it up from the library'**
  String get noStorePickup;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @buyingItems.
  ///
  /// In en, this message translates to:
  /// **'Purchase Items'**
  String get buyingItems;

  /// No description provided for @borrowingItems.
  ///
  /// In en, this message translates to:
  /// **'Borrowing Items'**
  String get borrowingItems;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @storePickup.
  ///
  /// In en, this message translates to:
  /// **'Library Pickup'**
  String get storePickup;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
