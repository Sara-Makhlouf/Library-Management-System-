import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart'; // استيراد حزمة الأنميشن
import 'package:library_mobile_app/core/theme.dart';

class PointsStickyNote extends StatelessWidget {
  final int points;

  const PointsStickyNote({Key? key, this.points = 150}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // 1. جسم الملاحظة الورقية مع التواء تفاعلي وظلال واقعية
            Transform.rotate(
              angle: 2.5 * math.pi / 180, // ميلان خفيف متناسق مع التصميم الأولي
              child: CustomPaint(
                size: const Size(120, 125),
                painter: RealisticCurledPaperPainter(
                  // ─── التعديل: تمرير ألوان الورقة والحواف بناءً على حالة الثيم ───
                  paperColor: isDark
                      ? AppColors.darkCard
                      : const Color(0xFFEFE3D3),
                  borderColor: isDark
                      ? AppColors.accentDark
                      : const Color(0xFFC6B49C), // لون الحواف الأغمق
                ),
                child: Container(
                  width: 120,
                  height: 115,
                  padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'نقاطي: $points',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          // ─── التعديل: لون النص بالوضع الداكن ───
                          color: isDark
                              ? AppColors.textDark
                              : const Color(0xFF3E2D1C),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),

                      // أيقونة العملات المعدنية والنجوم المتراكبة
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 14,
                              // ─── التعديل: لون النجوم المتلألئة بالوضع الداكن ───
                              color: isDark
                                  ? AppColors.primary.withOpacity(0.8)
                                  : const Color(0xFF8C7355).withOpacity(0.8),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.monetization_on_outlined,
                              size: 32,
                              // ─── التعديل: لون العملة المعدنية بالوضع الداكن ───
                              color: isDark
                                  ? AppColors.primary
                                  : const Color(0xFF8C7355),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. الدبوس الورقي العلوي مع ظل خفيف ليعطي انطباع البروز
            Positioned(
              top: -12,
              left: 48,
              child: Transform.rotate(
                angle: -12 * math.pi / 180,
                child: Icon(
                  Icons.attach_file,
                  size: 26,
                  // ─── التعديل: لون الدبوس (المشبك) ليصبح فاتحاً ومعدنياً أكثر في الدارك مود ───
                  color: isDark
                      ? const Color(0xFFD1D1D1)
                      : const Color(0xFF5A5A5A),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(1, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        // ─── تطبيق الأنميشن من اليمين إلى اليسار هنا ───
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
        .slideX(
          begin:
              0.4, // يبدأ الحركة من جهة اليمين (قيمة موجبة) ويتجه لليسار ليستقر عند 0
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// الرسم المطور خصيصاً للورقة بظلال ديناميكية وحواف داكنة دقيقة
class RealisticCurledPaperPainter extends CustomPainter {
  final Color paperColor;
  final Color borderColor;

  RealisticCurledPaperPainter({
    required this.paperColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // بناء هيكل الورقة
    path.moveTo(4, 4);
    path.quadraticBezierTo(size.width * 0.5, 1, size.width - 4, 3);
    path.lineTo(
      size.width,
      size.height - 20,
    ); // نقطة بداية الطية السفلية يميناً

    // رسم انثناء الزاوية السفلية (Page Curl Effect)
    path.lineTo(size.width - 20, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height - 2,
      4,
      size.height - 4,
    );
    path.quadraticBezierTo(1, size.height * 0.5, 4, 4);
    path.close();

    // --- 1. رسم الظل المتدرج الخارجي (Drop Shadow) ---
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path.shift(const Offset(2, 5)), shadowPaint);

    // --- 2. تلوين جسم الورقة الأساسي ---
    final bodyPaint = Paint()
      ..color = paperColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bodyPaint);

    // --- 3. رسم خط تحديد الحواف الداكن (Border Stroke) ---
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, borderPaint);

    // --- 4. رسم المثلث المطوي الصغير مع تظليله الداخلي الناعم ---
    final curlPath = Path();
    curlPath.moveTo(size.width, size.height - 20);
    curlPath.lineTo(size.width - 20, size.height);
    curlPath.quadraticBezierTo(
      size.width - 16,
      size.height - 16,
      size.width,
      size.height - 20,
    );
    curlPath.close();

    final curlPaint = Paint()
      // ─── التعديل: تفتيح/تغميق طية الورقة ديناميكياً بناءً على لون الخلفية لتبدو طبيعية بالوضعين ───
      ..color = Color.lerp(paperColor, Colors.black, 0.15)!
      ..style = PaintingStyle.fill;

    canvas.drawPath(curlPath, curlPaint);

    final curlBorderPaint = Paint()
      ..color = borderColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(curlPath, curlBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // تم التعديل إلى true لتحديث الألوان عند تبديل الثيم فورياً
}
