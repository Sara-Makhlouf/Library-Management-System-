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
  @override
  String get appl => 'App Langyage';
  @override
  String get borrowguide => 'Borrowing Guide';
  @override
  String get sendfedback => 'Send Feedback';
  @override
  String get rate => 'Rate the App';
  @override
  String get appv => 'App Version';
  @override
  String get terms => 'Terms & Conditions';
  @override
  String get privacy => 'Privacy Police';

  @override
  String get delete => 'Delete Account';
  @override
  String get push => 'Push Notification';
  @override
  String get borrow => 'Brows by category';
  @override
  String get art => 'Art & Literature';
  @override
  String get Economics => 'Economics';
  @override
  String get historyc => 'History';
  @override
  String get Novels => 'Novels';
  @override
  String get philosophyc => 'Philosophy';
  @override
  String get sciencec => 'Science';
  @override
  String get tech => 'Technology';
  @override
  String get bills => 'My Bills';
  @override
  String get bookrequest => 'Book Request';
  @override
  String get waitinglist => 'Waiting List';
  @override
  String get help => 'Help & Support';
  @override
  String get total => 'Total amount';
  @override
  String get invoice => 'Incvoice';
  @override
  String get myinvoice => 'My Invoice';
  @override
  String get invhistory => 'Your invoice history';
  @override
  String get norequest => 'No Book Request yet';
  @override
  String get newrequest => 'Request a Book';
  @override
  String get newsinc =>
      'Request a book that is not currently available in the libralry.';
  // Action sheet / Dialogs
  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get chooseAnActionForThisBook => 'Choose an action for this book';

  @override
  String get buyThisBook => 'Buy this book';

  // Shopping Cart & Empty states
  @override
  String get reviewYourSelectedBooks => 'Review your selected books';

  @override
  String get addBooksToYourCart =>
      'Add books to your cart and they will appear here';

  // Book Details & Overview
  @override
  String get copies => 'Copies';

  @override
  String get language => 'Language';

  @override
  String get pages => 'Pages';

  @override
  String get overview => 'Overview';

  @override
  String get bookInformation => 'Book Information';

  @override
  String get author => 'Author';

  @override
  String get availability => 'Availability';

  @override
  String get available => 'Available';

  @override
  String get price => 'Price';

  @override
  String get writeReview => 'Write review';

  @override
  String get reviews => 'Reviews';

  @override
  String get readersRating => 'Readers rating';

  @override
  String get getBook => 'Get Book';

  @override
  String get readBook => 'Read Book';

  // Sorting
  @override
  String get sortBooks => 'Sort books';

  @override
  String get chooseHowToViewBooks => 'Choose how you want to view the books';

  @override
  String get titleAZ => 'Title A-Z';

  @override
  String get priceLowHigh => 'Price Low-High';

  @override
  String get priceHighLow => 'Price High-Low';

  // Notifications
  @override
  String get notifications => 'Notifications';

  @override
  String get readAll => 'Read all';

  @override
  String get read => 'Read';

  @override
  String get unread => 'Unread';

  // Waiting List
  @override
  String get noWaitingListRequests => 'No waiting list requests';

  @override
  String get waitingListSubtitle =>
      'Books you add to waiting list will appear here';

  // Contact Us & Messages
  @override
  String get feelFreeToReachOut => 'Feel free to reach out to us';

  @override
  String get getInTouch => 'Get in touch';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get libraryLocation => 'Library Location';

  @override
  String get sendUsAMessage => 'Send us a message';

  @override
  String get yourName => 'Your name';

  @override
  String get yourEmail => 'Your email';

  @override
  String get writeYourMessage => 'Write your message...';

  @override
  String get sendMessage => 'Send Message';

  // General Actions
  @override
  String get view => 'View';
  // Sorting & Header details (من صوري القائمة والأصناف)
  @override
  String booksCountHeader(int count) {
    return 'books $count';
  }

  // Card Badges (من صور تفاصيل الكتاب وسلة المشتريات)
  @override
  String get newBadge => 'NEW';

  // Additional Contact Info
  @override
  String get universityLibrary => 'University Library';

  // Book Action Buttons
  @override
  String get borrowAction => 'Borrow';
  @override
  String get fav => 'Your favourite are empty ';
  @override
  String get favsave =>
      'Save the books you love and find them here whenever you want ';
}
