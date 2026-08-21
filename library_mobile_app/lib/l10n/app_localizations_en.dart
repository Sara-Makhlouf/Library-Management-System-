// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get appLanguage => 'App Language';

  @override
  String get home => 'Home';

  @override
  String get searchPlaceholder => 'Search Your Book...';

  @override
  String points(Object count) {
    return 'Points: $count';
  }

  @override
  String get mostPopular => 'Most popular';

  @override
  String get bookCategories => 'Book categories';

  @override
  String get philosophy => 'Philosophy';

  @override
  String get literatureAndNovels => 'Literature & Novels';

  @override
  String get history => 'History';

  @override
  String get science => 'Science';

  @override
  String get selfDevelopment => 'Self-development';

  @override
  String get borrowingRecord => 'Borrowing Record';

  @override
  String get myOrdersAndDelivery => 'My Orders & Delivery';

  @override
  String get profile => 'Profile';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get logout => 'Log Out';

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get buyingTab => 'Buying';

  @override
  String get borrowingTab => 'Borrowing';

  @override
  String borrowPrice(String price) {
    return 'Borrow Fee: $price SYP';
  }

  @override
  String buyPrice(Object price) {
    return 'Buying price: $price SYP';
  }

  @override
  String get confirmOrderAndPay => 'Confirm Order & Pay';

  @override
  String get checkoutAndPayment => 'Checkout & Payment';

  @override
  String get invoiceSummary => 'Invoice Summary';

  @override
  String get buyingBooks => 'Books for Purchase';

  @override
  String get borrowingBooks => 'Books for Borrowing';

  @override
  String itemsCount(Object count) {
    return '$count Items';
  }

  @override
  String get totalPrice => 'Total Price';

  @override
  String get currency => 'SYP';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get detailedAddress => 'Detailed Address';

  @override
  String get deliveryService => 'Delivery Service';

  @override
  String get yesDelivery => 'Yes, I want delivery';

  @override
  String get noDelivery => 'No, I will pick it up';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get creditCard => 'Credit Card / Electronic Payment';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get borrowingTerms => 'Borrowing Terms & Notes';

  @override
  String get importantNoteBorrow => 'Important Note for Borrowed Books';

  @override
  String get borrowPeriodNotice =>
      'The maximum borrowing period is 7 days. Please return the books on time to avoid fines.';

  @override
  String get confirmOrderNow => 'Confirm Order Now';

  @override
  String get orderReceived => 'Order Received Successfully!';

  @override
  String get orderId => 'Order ID';

  @override
  String orderDate(Object date) {
    return 'Date: $date';
  }

  @override
  String get deliveryRequested => 'Delivery: Requested';

  @override
  String get deliveryNotRequested => 'Delivery: Self Pickup';

  @override
  String get backToHome => 'Back to Home';

  @override
  String booksCount(Object count) {
    return '$count books';
  }

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortDefault => 'Default';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortPrice => 'Price';

  @override
  String get free => 'Free';

  @override
  String get favouritePage => 'Favourite Page';

  @override
  String get orderHistory => 'OrderHistory';

  @override
  String myPoints(int points) {
    return 'My Points: $points';
  }

  @override
  String get bookGhadrAlSalafiya => 'Ghadr Al-Salafiya';

  @override
  String get authorEzzElDin => 'Ezz El-Din';

  @override
  String get bookAncientLibrary => 'Novel:\nThe Ancient Library';

  @override
  String get authorGarmoush => 'Garmoush';

  @override
  String get bookTheSpider => 'The Spider';

  @override
  String get authorDawnWizard => 'Dawn Wizard';

  @override
  String get searchYourBook => 'Search your book';

  @override
  String get noItemsInSection => 'NoItemsInSection';

  @override
  String purchasePrice(String price) {
    return 'Purchase Price: $price SYP';
  }

  @override
  String get yesWantsDelivery => 'Yes, I want home delivery';

  @override
  String get noStorePickup => 'No, I will pick it up from the library';

  @override
  String get date => 'Date';

  @override
  String get buyingItems => 'Purchase Items';

  @override
  String get borrowingItems => 'Borrowing Items';

  @override
  String get requested => 'Requested';

  @override
  String get storePickup => 'Library Pickup';
}
