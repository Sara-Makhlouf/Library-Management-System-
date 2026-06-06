import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // ─── التعديل: تغيير لون الخلفية للحقل في الدارك مود ───
              color: isDark ? AppColors.inputDark : AppColors.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // تخفيف حدة الظل في الوضع الداكن لتبدو الواجهة مريحة
                  color: isDark ? Colors.black38 : Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              textAlign: TextAlign.left,
              // ─── التعديل: لون النص المكتوب يتغير حسب الوضع ليكون واضحاً ───
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Search Your Book", // تصحيح إملائي بسيط لـ Your
                hintStyle: TextStyle(
                  // ─── التعديل: لون نص التلميح التوضيحي متوافق مع الثيمين ───
                  color: isDark
                      ? AppColors.textGrey
                      : const Color.fromARGB(179, 138, 136, 136),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  // ─── التعديل: تلوين أيقونة البحث بالذهبي بالداكن لتبرز بشكل جميل ───
                  color: isDark ? AppColors.primary : AppColors.textGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ─── تهيئة الزر المعلق ليدعم الداكن فوراً عند تفعيله وفك التعليق عنه ───
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black38,
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              print('Sort pressed');
            },
            icon: Icon(
              Icons.sort_by_alpha,
              // الأيقونة تصبح ذهبية في الداكن لتتناسب مع هوية التطبيق البصرية
              color: isDark ? AppColors.primary : Color(0xFF685A39),
            ),
          ),
        ),
      ],
    );
  }
}
