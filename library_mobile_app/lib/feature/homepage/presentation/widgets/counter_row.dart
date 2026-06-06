import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart'; // استيراد ملف الألوان للتكامل مع الثيم

// التعديل: إضافة BuildContext كمعامل للدالة لقراءة حالة الثيم فورياً
Widget buildCounterRow(
  BuildContext context,
  String label,
  int value,
  Function(int) onChanged,
) {
  // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          // ─── التعديل: تلوين النص الخارجي باللون الفاتح في الدارك مود لكي لا يختفي ───
          color: isDark ? AppColors.textDark : Colors.black87,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          // ─── التعديل: تحويل خلفية العداد للون الحقول الداكنة في الدارك مود ───
          color: isDark ? AppColors.inputDark : const Color(0xff3A7CA5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                // ─── التعديل: جعل لون الأيقونة ذهبياً بالدارك مود ليتماشى مع كود محمد ───
                color: isDark ? AppColors.primary : Colors.white,
              ),
              onPressed: () {
                if (value > 1) onChanged(value - 1);
              },
            ),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 16,
                // ─── التعديل: تلوين رقم العداد باللون الفاتح بالدارك مود ───
                color: isDark ? AppColors.textDark : Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? AppColors.primary : Colors.white,
              ),
              onPressed: () {
                onChanged(value + 1);
              },
            ),
          ],
        ),
      ),
    ],
  );
}
