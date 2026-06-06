import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_mobile_app/core/locale_cubit.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

// الاستدعاءات المباشرة الصحيحة 100% حسب مكان الـ main 👇
import '../../core/constant.dart';
import '../../core/theme.dart';
import '../../core/theme_cubit.dart';
import '../../core/app_router.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── التعديل هنا لضمان قراءة الثيم المحفوظ قبل بناء الواجهات ───
  // إذا كان محمد مستخدماً HydratedBloc لتخزين الثيم، ستحتاجين لتهيئة مسار التخزين هنا:
  // await HydratedBloc.storage = await HydratedStorage.build(
  //   storageDirectory: await getApplicationDocumentsDirectory(),
  // );

  // أما إذا كان الاعتماد على SharedPreferences العادية داخل الـ Cubit، فالكود الحالي يكفي
  // طالما يتم استدعاء تهيئتها داخل الـ ThemeCubit نفسه.

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // 💡 تأكدي أن الـ ThemeCubit يستدعي دالة لود الثيم المحفوظ عند إنشائه، مثلاً:
          create: (context) =>
              ThemeCubit(), // أو يقرأها مباشرة بالـ Constructor
        ),
        BlocProvider(
          create: (context) => LocaleCubit(), // إضافة كابيت اللغة
        ),
      ],
      // ─── تم إصلاح الدمج والترتيب هنا ───
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Hibr & Waraq',

                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,

                // ─── إعدادات اللغة المدعومة تلقائياً ───
                locale: localeState,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                // إعدادات المسارات والراوتر المنظم (شغلك أنتِ) 👇
                initialRoute: Routes.initialRoute,
                onGenerateRoute: AppRouter.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
