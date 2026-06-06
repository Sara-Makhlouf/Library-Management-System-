import 'dart:async'; // تم إضافة هذه المكتبة للتحكم بالـ Timer
import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart'; // استيراد ملف الألوان للتكامل مع الثيم

class PopularBooksSlider extends StatefulWidget {
  const PopularBooksSlider({Key? key}) : super(key: key);

  @override
  State<PopularBooksSlider> createState() => _PopularBooksSliderState();
}

class _PopularBooksSliderState extends State<PopularBooksSlider> {
  late PageController _pageController;
  double _currentPage = 1.0; // البداية من الكتاب الأوسط الافتراضي
  Timer? _autoScrollTimer; // مؤقت التحكم بالحركة التلقائية

  // بيانات الصور للروايات والكتب
  final List<Map<String, String>> books = [
    {
      "title": "غدر السلفية",
      "author": "عز الدين",
      "image": "assets/images/bookHis1.png",
    },
    {
      "title": "رواية:\nالمكتبة العتيقة",
      "author": "غارمورش",
      "image": "assets/images/bookHis1.png",
    },
    {
      "title": "العنكبوت",
      "author": "ساحر الفجر",
      "image": "assets/images/bookHis1.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    // viewportFraction: 0.55 تعني أن الكتاب يأخذ نصف عرض الشاشة والجانبيات تظهر حوله
    _pageController = PageController(initialPage: 1, viewportFraction: 0.55);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    // استدعاء دالة التحريك التلقائي عند بناء الويدجت
    _startAutoScroll();
  }

  // دالة تشغيل التحريك التلقائي
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;

        // إذا وصلنا إلى نهاية القائمة، نعود للكتاب الأول
        if (nextPage >= books.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800), // مدة حركة الانتقال
          curve:
              Curves.easeInOutCubic, // منحنى حركة ناعم وانسيابي ثلاثي الأبعاد
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel(); // إيقاف المؤقت عند الخروج لحماية الذاكرة
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 250, // الارتفاع المتوافق لعرض الكاروسيل بالكامل
          // استخدام Listener للاستماع لسحب المستخدم يدويًا لإيقاف وتجديد الانميشن لتجنب التضارب
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _autoScrollTimer
                    ?.cancel(); // إيقاف المؤقت مؤقتًا أثناء سحب المستخدم
              } else if (notification is ScrollEndNotification) {
                _autoScrollTimer?.cancel();
                _startAutoScroll(); // إعادة تشغيل المؤقت بعد انتهاء السحب اليدوي
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: books.length,
              physics: const BouncingScrollPhysics(), // سحب ناعم وتفاعلي
              itemBuilder: (context, index) {
                // حساب مدى بعد الكتاب عن المركز الحالي للتحكم بحجمه وميلانه
                double value = _currentPage - index;

                // مصفوفة التحجيم والميلان ثلاثي الأبعاد
                Matrix4 matrix = Matrix4.identity();

                if (value == 0) {
                  // الكتاب في المنتصف تماماً
                  matrix = Matrix4.identity()..scale(1.0);
                } else {
                  // الكتب الجانبية: يتم تصغيرها ونقلها للخلف لتبدو متراصة خلف بعضها
                  double scale = (1 - (value.abs() * 0.15)).clamp(0.8, 1.0);
                  double translation =
                      value * 25.0; // تقريب الكتب لبعضها بالخلف
                  matrix = Matrix4.identity()
                    ..scale(scale)
                    ..translate(-translation, value.abs() * 8);
                }

                return Transform(
                  transform: matrix,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // صورة الغلاف الخلفية للكتاب الكلاسيكي
                            Image.asset(
                              books[index]['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                // ─── التعديل: تلوين خلفية غياب الصورة بالثيم المناسب ───
                                color: isDark
                                    ? AppColors.darkCard
                                    : const Color(0xFFEFE3D3),
                                child: Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 50,
                                    // ─── التعديل: لون الأيقونة البديلة بالداكن والنهاري ───
                                    color: isDark
                                        ? AppColors.textGrey
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            // الغشاء المتدرج الداكن لكتابة النصوص بوضوح فوق الغلاف
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                            // النصوص فوق غلاف الكتاب (العنوان والمؤلف)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        // ─── التعديل: استخدام اللون الذهبي الثابت للتاق من كلاس التيم ليكون متناسقاً بالوضعين ───
                                        color: AppColors.primary.withOpacity(
                                          0.85,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "الأكثر شهرة:",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        books[index]['title']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        books[index]['author']!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
