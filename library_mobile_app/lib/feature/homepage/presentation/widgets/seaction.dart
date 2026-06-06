import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';

class Section extends StatelessWidget {
  const Section({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildInkWellItem(context, 'Category', Icons.category),
            _buildInkWellItem(context, 'Delivery', Icons.directions_car),
            _buildInkWellItem(context, 'MyOrders', Icons.receipt_long),
            _buildInkWellItem(context, 'My points', Icons.point_of_sale),
          ],
        ),
      ),
    );
  }

  Widget _buildInkWellItem(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SectionIcon(
        title: title,
        icon: icon,
        onTap: () {
          if (title == 'Category') {
            Navigator.of(context).pushNamed(
              Routes.book,
              arguments: 'assets/images/book_placeholder.png',
            );
          } else {
            print("$title pressed");
          }
        },
      ),
    );
  }
}

class SectionIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const SectionIcon({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            // ─── التعديل: خلفية الدائرة تصبح داكنة في الدارك مود ───
            backgroundColor: isDark ? AppColors.darkCard : AppColors.secondary,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: onTap,
                child: Center(
                  child: Icon(
                    icon,
                    // ─── التعديل: تلوين الأيقونة بالذهبي لتبرز في الوضع الداكن ───
                    color: isDark ? AppColors.primary : AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              // ─── التعديل: تلوين النص باللون الفاتح في الدارك مود لكي لا يختفي ───
              color: isDark ? AppColors.textDark : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
