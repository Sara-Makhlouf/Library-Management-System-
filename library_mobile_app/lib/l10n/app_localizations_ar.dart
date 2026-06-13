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
  String get profile => 'البروفايل';

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
    return 'Buying price: $price SYP';
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
  String get orderReceived => 'تم استلام طلبكِ بنجاح!';

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
  String get authorGarmoush => 'غارمورش';

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
}
