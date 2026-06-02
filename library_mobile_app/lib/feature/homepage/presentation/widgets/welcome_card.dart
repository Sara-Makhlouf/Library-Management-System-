import 'package:flutter/material.dart';

// الكود مجهز ليتم وضعه مباشرة في واجهتك الرئيسية (Home Screen)
class CardsSection extends StatelessWidget {
  const CardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        children: [
          // 1. بطاقة الترحيب (الجهة اليمنى)
          Expanded(child: const WelcomeCard()),
          const SizedBox(width: 16), // مسافة فاصلة بين البطاقتين
          // 2. بطاقة اقتباس اليوم (الجهة اليسرى)
          Expanded(child: const QuoteOfTheDayCard()),
        ],
      ),
    );
  }
}

// --- تصميم بطاقة الترحيب ---
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170, // طول مناسب ليتناسق مع شاشة الهاتف
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5DCD3), // اللون البيج الغامق للبطاقة
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الجزء العلوي: النص الترحيبي والصورة الشخصية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'مرحباً غفران،',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ماذا سنقرأ اليوم؟',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // الصورة الشخصية الدائرية (Avatar)
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF8B817A),
                child: Icon(Icons.person, color: Colors.white, size: 20),
                // يمكنكِ استبدال الأيقونة بصورة حقيقية عبر:
                // backgroundImage: AssetImage('assets/images/user.png'),
              ),
            ],
          ),

          // الخط الفاصل
          Divider(color: Colors.black12, thickness: 1),

          // الجزء السفلي: حالة القراءة والنقاط
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لديك كتاب قيد القراءة (أنتاركتيكا)',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Tajawal',
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text(
                    'نقاطك الحالية: ',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Tajawal',
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '150',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Color(0xFF6E5A4E), // لون بني مميز للرقم
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- تصميم بطاقة اقتباس اليوم ---
class QuoteOfTheDayCard extends StatelessWidget {
  const QuoteOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EAE4), // لون أفتح قليلاً للتباين
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4B5A8), // حدود خفيفة لتشبه الكرت الإهداء
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // أيقونة الحفظ (Bookmark) في الأعلى على اليسار (أو اليمين حسب اتجاه التطبيق)
          const Align(
            alignment: Alignment.topLeft,
            child: Icon(
              Icons.bookmark_border,
              color: Color(0xFF8B817A),
              size: 20,
            ),
          ),

          // محتوى الاقتباس واسم الكاتب
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 10), // مسافة لأجل الأيقونة
              Text(
                '"الكتاب هو المعلم الوحيد الذي يعطيك بلا حدود."',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Tajawal',
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '- الجاحظ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: Color(0xFF8B817A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
