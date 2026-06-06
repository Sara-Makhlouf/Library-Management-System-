import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // استيراد حزمة الأنميشن
import 'package:library_mobile_app/core/constant.dart';
// ─── التعديل: استيراد كلاس الألوان للوصول إلى متغيرات الثيم ───
import 'package:library_mobile_app/core/theme.dart';

class BookCategoriesSection extends StatelessWidget {
  const BookCategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> categories = [
      {
        'title': 'تاريخ',
        'image': 'assets/images/photo_2026-06-05_16-09-20.jpg',
      },
      {
        'title': 'أدب وروايات',
        'image': 'assets/images/photo_2026-06-05_16-09-03.jpg',
      },
      {
        'title': 'فلسفة',
        'image': 'assets/images/photo_2026-06-05_16-09-03.jpg',
      },
      {
        'title': 'تطوير ذات',
        'image': 'assets/images/photo_2026-06-05_16-09-09.jpg',
      },
      {'title': 'علوم', 'image': 'assets/images/photo_2026-06-05_16-09-09.jpg'},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Book categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // ─── التعديل: تلوين العنوان الرئيسي بالذهبي في الدارك مود ───
                  color: isDark ? AppColors.primary : const Color(0xFF685A39),
                ),
              ),
            ),
            const SizedBox(height: 15),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];

                return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.book,
                          arguments: category['title'],
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                // ─── التعديل: تلوين خلفية الحاوية بلون الكارت الداكن في الدارك مود ───
                                color: isDark
                                    ? AppColors.darkCard
                                    : const Color(0xFFD8C8A8),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  category['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // ─── التعديل: تلوين اسم الفئة باللون الفاتح المخصص للدارك مود ───
                              color: isDark
                                  ? AppColors.textDark
                                  : const Color(0xFF2C1E11),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 80 * index),
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideX(
                      begin: -0.3,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
