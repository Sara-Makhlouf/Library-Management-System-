import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  // القائمة الخاصة بالصور لتسهيل التعامل معها وتجنب التكرار
  final List<String> imgList = [
    'lib/assets/images/photo_2026-04-22_18-20-25.jpg',
    'lib/assets/images/photo_2026-04-22_18-20-33.jpg',
    'lib/assets/images/photo_2026-04-22_18-20-40.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      // تقليل الـ Padding الجانبي ليأخذ السلايدر مساحة مريحة
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: CarouselSlider(
        items: imgList
            .map(
              (item) => Container(
                // الـ ClipRRect هو السر لقص حواف الصورة لتصبح دائرية ومتناسقة
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // تدوير حواف احترافي ومناسب
                  child: Image.asset(
                    item,
                    fit: BoxFit
                        .cover, // هذا السطر يمنع تشوه الصورة ويجعلها تملأ المساحة بالكامل
                    width: double.infinity, // لتأخذ الصورة كامل عرض الكارد
                  ),
                ),
              ),
            )
            .toList(),
        options: CarouselOptions(
          autoPlay: true,
          height: 200, // تحديد الارتفاع داخل خيارات السلايدر مباشرة
          autoPlayInterval: const Duration(
            seconds: 4,
          ), // تعديل وقت العرض لراحة العين
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage:
              true, // تضخيم الصورة النشطة بالمنتصف لحركة الـ Carousel
          viewportFraction:
              0.9, // يظهر أجزاء بسيطة من الصور الجانبية ليعرف المستخدم أنه متحرك
        ),
      ),
    );
  }
}
