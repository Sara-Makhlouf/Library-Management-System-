// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get lightMode => 'الوضع النهاري';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get home => 'الرئيسية';

  @override
  String get searchPlaceholder => 'ابحث عن كتابك...';

  @override
  String points(Object count) {
    return 'نقاطي: $count';
  }

  @override
  String get mostPopular => 'الأكثر شعبية';

  @override
  String get bookCategories => 'تصنيفات الكتب';

  @override
  String get philosophy => 'فلسفة';

  @override
  String get literatureAndNovels => 'أدب وروايات';

  @override
  String get history => 'تاريخ';

  @override
  String get science => 'علوم';

  @override
  String get selfDevelopment => 'تطوير ذات';

  @override
  String get borrowingRecord => 'سجل الاستعارات';

  @override
  String get myOrdersAndDelivery => 'طلباتي والتوصيل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get shoppingCart => 'سلة المشتريات';

  @override
  String get buyingTab => 'الشراء';

  @override
  String get borrowingTab => 'الاستعارة';

  @override
  String borrowPrice(String price) {
    return 'رسم استعارة: $price ل.س';
  }

  @override
  String buyPrice(Object price) {
    return 'سعر الشراء: $price ل.س';
  }

  @override
  String get confirmOrderAndPay => 'تأكيد الطلب والدفع';

  @override
  String get checkoutAndPayment => 'الدفع وإتمام الطلب';

  @override
  String get invoiceSummary => 'ملخص الفاتورة';

  @override
  String get buyingBooks => 'كتب للشراء';

  @override
  String get borrowingBooks => 'كتب للاستعارة';

  @override
  String itemsCount(Object count) {
    return '$count عناصر';
  }

  @override
  String get totalPrice => 'السعر الإجمالي';

  @override
  String get currency => 'ل.س';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get detailedAddress => 'العنوان التفصيلي';

  @override
  String get deliveryService => 'خدمة التوصيل';

  @override
  String get yesDelivery => 'نعم، أريد التوصيل';

  @override
  String get noDelivery => 'لا، سأقوم باستلامها بنفسي';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get creditCard => 'بطاقة ائتمان / دفع إلكتروني';

  @override
  String get cashOnDelivery => 'الدفع نقداً عند الاستلام';

  @override
  String get borrowingTerms => 'شروط وملاحظات الاستعارة';

  @override
  String get importantNoteBorrow => 'ملاحظة هامة بخصوص الكتب المستعارة';

  @override
  String get borrowPeriodNotice =>
      'الحد الأقصى للاستعارة هو 7 أيام فقط. يرجى الالتزام بالموعد لتجنب الغرامات.';

  @override
  String get confirmOrderNow => 'تأكيد الطلب الآن';

  @override
  String get orderReceived => 'تم استلام طلبك بنجاح!';

  @override
  String get orderId => 'رقم الطلب';

  @override
  String orderDate(Object date) {
    return 'التاريخ: $date';
  }

  @override
  String get deliveryRequested => 'التوصيل: مطلوب';

  @override
  String get deliveryNotRequested => 'التوصيل: استلام شخصي';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String booksCount(Object count) {
    return '$count كتب';
  }

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortDefault => 'الافتراضي';

  @override
  String get sortTitle => 'العنوان';

  @override
  String get sortPrice => 'السعر';

  @override
  String get free => 'مجاني';

  @override
  String get favouritePage => 'الصفحة المفضلة';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String myPoints(int points) {
    return 'نقاطي: $points';
  }

  @override
  String get bookGhadrAlSalafiya => 'غدر السلفية';

  @override
  String get authorEzzElDin => 'عز الدين';

  @override
  String get bookAncientLibrary => 'رواية:\nالمكتبة العتيقة';

  @override
  String get authorGarmoush => 'غارموش';

  @override
  String get bookTheSpider => 'العنكبوت';

  @override
  String get authorDawnWizard => 'ساحر الفجر';

  @override
  String get searchYourBook => 'ابحث عن كتابك';

  @override
  String get noItemsInSection => 'لا توجد عناصر في هذا القسم';

  @override
  String purchasePrice(String price) {
    return 'سعر الشراء: $price ل.س';
  }

  @override
  String get yesWantsDelivery => 'نعم، أريد التوصيل إلى عنواني';

  @override
  String get noStorePickup => 'لا، سأقوم باستلامها بنفسي من المكتبة';

  @override
  String get date => 'التاريخ';

  @override
  String get buyingItems => 'عدد كتب الشراء';

  @override
  String get borrowingItems => 'عدد كتب الاستعارة';

  @override
  String get requested => 'مطلوب';

  @override
  String get storePickup => 'استلام من المكتبة';

  @override
  String get appl => 'لغة التطبيق';

  @override
  String get borrowguide => 'دليل الاستعارة';

  @override
  String get sendfedback => 'إرسال ملاحظات';

  @override
  String get rate => 'تقييم التطبيق';

  @override
  String get appv => 'إصدار التطبيق';

  @override
  String get terms => 'الشروط والأحكام';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get delete => 'حذف الحساب';

  @override
  String get push => 'الإشعارات المفعلة';

  @override
  String get borrow => 'التصفح حسب التصنيف';

  @override
  String get art => 'الفن والأدب';

  @override
  String get Economics => 'الاقتصاد';

  @override
  String get historyc => 'التاريخ';

  @override
  String get Novels => 'الروايات';

  @override
  String get philosophyc => 'الفلسفة';

  @override
  String get sciencec => 'العلوم';

  @override
  String get tech => 'التكنولوجيا';

  @override
  String get bills => 'فواتيري';

  @override
  String get bookrequest => 'طلب كتاب';

  @override
  String get waitinglist => 'قائمة الانتظار';

  @override
  String get help => 'المساعدة والدعم';

  @override
  String get total => 'المبلغ الإجمالي';

  @override
  String get invoice => 'الفاتورة';

  @override
  String get myinvoice => 'فاتورتي';

  @override
  String get invhistory => 'سجل فواتيرك';

  @override
  String get norequest => 'لا توجد طلبات كتب بعد';

  @override
  String get newrequest => 'طلب كتاب جديد';

  @override
  String get newsinc => 'اطلب كتاباً غير متوفر حالياً في المكتبة.';

  // Action sheet / Dialogs
  @override
  String get whatWouldYouLikeToDo => 'ماذا تريد أن تفعل؟';

  @override
  String get chooseAnActionForThisBook => 'اختر إجراءً لهذا الكتاب';

  @override
  String get buyThisBook => 'شراء هذا الكتاب';

  // Shopping Cart & Empty states
  @override
  String get reviewYourSelectedBooks => 'مراجعة الكتب المختارة';

  @override
  String get addBooksToYourCart => 'أضف كتباً إلى سلة التسوق وستظهر هنا';

  // Book Details & Overview
  @override
  String get copies => 'النسخ';

  @override
  String get language => 'اللغة';

  @override
  String get pages => 'الصفحات';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get bookInformation => 'معلومات الكتاب';

  @override
  String get author => 'المؤلف';

  @override
  String get availability => 'التوفر';

  @override
  String get available => 'متوفر';

  @override
  String get price => 'السعر';

  @override
  String get writeReview => 'كتابة مراجعة';

  @override
  String get reviews => 'المراجعات';

  @override
  String get readersRating => 'تقييم القراء';

  @override
  String get getBook => 'احصل على الكتاب';

  @override
  String get readBook => 'قراءة الكتاب';

  // Sorting
  @override
  String get sortBooks => 'ترتيب الكتب';

  @override
  String get chooseHowToViewBooks => 'اختر طريقة عرض الكتب';

  @override
  String get titleAZ => 'العنوان أ-ي';

  @override
  String get priceLowHigh => 'السعر من الأقل للأعلى';

  @override
  String get priceHighLow => 'السعر من الأعلى للأقل';

  // Notifications
  @override
  String get notifications => 'الإشعارات';

  @override
  String get readAll => 'تحديد الكل كمقروء';

  @override
  String get read => 'المقروءة';

  @override
  String get unread => 'غير المقروءة';

  // Waiting List
  @override
  String get noWaitingListRequests => 'لا توجد طلبات في قائمة الانتظار';

  @override
  String get waitingListSubtitle =>
      'الكتب التي تضيفها إلى قائمة الانتظار ستظهر هنا';

  // Contact Us & Messages
  @override
  String get feelFreeToReachOut => 'لا تتردد في التواصل معنا';

  @override
  String get getInTouch => 'ابقَ على تواصل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get libraryLocation => 'موقع المكتبة';

  @override
  String get sendUsAMessage => 'أرسل لنا رسالة';

  @override
  String get yourName => 'اسمك';

  @override
  String get yourEmail => 'بريدك الإلكتروني';

  @override
  String get writeYourMessage => 'اكتب رسالتك...';

  @override
  String get sendMessage => 'إرسال الرسالة';

  // General Actions
  @override
  String get view => 'عرض';

  // Sorting & Header details
  @override
  String booksCountHeader(int count) {
    return 'الكتب $count';
  }

  // Card Badges
  @override
  String get newBadge => 'جديد';

  // Additional Contact Info
  @override
  String get universityLibrary => 'مكتبة الجامعة';

  // Book Action Buttons
  @override
  String get borrowAction => 'استعارة';

  @override
  String get fav => 'قائمة المفضلة فارغة';

  @override
  String get favsave => 'احفظ الكتب التي تحبها لتجدها هنا وقتما تشاء';
}
