import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:library_mobile_app/core/locale_cubit.dart';
import 'package:library_mobile_app/feature/homepage/bloc/app_bloc_observer.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

import 'core/constantPage.dart';
import '../../core/theme.dart';
import '../../core/theme_cubit.dart';
import '../../core/app_router.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// =======================================================
/// BACKGROUND FCM HANDLER
/// =======================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('========================================');
  debugPrint('🔵 FCM BACKGROUND MESSAGE');
  debugPrint('🆔 ID: ${message.messageId}');
  debugPrint('🔔 TITLE: ${message.notification?.title}');
  debugPrint('📝 BODY: ${message.notification?.body}');
  debugPrint('📦 DATA: ${message.data}');
  debugPrint('========================================');

  // ⚠️ إذا الباك عم يرسل notification payload
  // Firebase/Android بيعرض الإشعار تلقائياً بالخلفية.
  //
  // لذلك لا نعمل local notification هون
  // حتى ما يطلع الإشعار مرتين.
}

/// =======================================================
/// LOCAL NOTIFICATION INITIALIZATION
/// =======================================================

Future<void> initializeLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,

    // الضغط على Local Notification
    onDidReceiveNotificationResponse: (response) {
      debugPrint('👆 LOCAL NOTIFICATION CLICKED');

      final payload = response.payload;

      debugPrint('📦 PAYLOAD: $payload');

      if (payload != null && payload.isNotEmpty) {
        handleNotificationNavigation(payload);
      }
    },
  );

  // Android notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'library_notifications',
    'Library Notifications',
    description: 'Library application notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// =======================================================
/// FOREGROUND NOTIFICATION
/// =======================================================

void setupForegroundNotifications() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('========================================');
    debugPrint('🟢 FCM FOREGROUND MESSAGE');
    debugPrint('📱 APP STATE: FOREGROUND');
    debugPrint('🆔 MESSAGE ID: ${message.messageId}');
    debugPrint('🔔 TITLE: ${message.notification?.title}');
    debugPrint('📝 BODY: ${message.notification?.body}');
    debugPrint('📦 DATA: ${message.data}');
    debugPrint('========================================');

    final notification = message.notification;

    if (notification == null) return;

    final title = notification.title ?? 'Library';

    final body = notification.body ?? '';

    final payload = message.data.toString();

    const androidDetails = AndroidNotificationDetails(
      'library_notifications',
      'Library Notifications',
      channelDescription: 'Library application notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  });
}

/// =======================================================
/// BACKGROUND CLICK
/// =======================================================

void setupNotificationClickHandling() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('========================================');
    debugPrint('👆 BACKGROUND NOTIFICATION CLICKED');
    debugPrint('🆔 MESSAGE ID: ${message.messageId}');
    debugPrint('📦 DATA: ${message.data}');
    debugPrint('========================================');

    handleNotificationData(message.data);
  });
}

/// =======================================================
/// APP TERMINATED CLICK
/// =======================================================

Future<void> checkInitialNotification() async {
  final RemoteMessage? message = await FirebaseMessaging.instance
      .getInitialMessage();

  if (message == null) {
    debugPrint('ℹ️ App opened normally - no notification');
    return;
  }

  debugPrint('========================================');
  debugPrint('🚀 APP OPENED FROM TERMINATED STATE');
  debugPrint('🆔 MESSAGE ID: ${message.messageId}');
  debugPrint('📦 DATA: ${message.data}');
  debugPrint('========================================');

  // ننتظر Flutter لحتى يجهز
  WidgetsBinding.instance.addPostFrameCallback((_) {
    handleNotificationData(message.data);
  });
}

/// =======================================================
/// HANDLE FIREBASE DATA
/// =======================================================

void handleNotificationData(Map<String, dynamic> data) {
  debugPrint('🔀 HANDLING NOTIFICATION DATA');
  debugPrint('📦 $data');

  final targetScreen = data['target_screen']?.toString();

  debugPrint('🎯 TARGET SCREEN: $targetScreen');

  if (targetScreen == null) return;

  switch (targetScreen) {
    case 'home_dashboard':
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.notifications,
        (route) => false,
      );
      break;

    default:
      debugPrint('⚠️ Unknown target screen: $targetScreen');
  }
}

/// =======================================================
/// HANDLE LOCAL PAYLOAD
/// =======================================================

void handleNotificationNavigation(String payload) {
  debugPrint('🔀 LOCAL PAYLOAD: $payload');

  // payload حالياً جاي بالشكل:
  //
  // {target_screen: home_dashboard, notification_id: 40, type: welcome_notification}
  //
  // لذلك نقرأ target_screen بشكل بسيط.

  if (payload.contains('home_dashboard')) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.notifications,
      (route) => false,
    );
  }
}

/// =======================================================
/// MAIN
/// =======================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  printNetworkConfig();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Notification permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Local notifications
  await initializeLocalNotifications();

  // Foreground
  setupForegroundNotifications();

  // Background click
  setupNotificationClickHandling();

  // Terminated click
  await checkInitialNotification();

  // FCM Token
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    debugPrint('========================================');
    debugPrint('🔥 FCM TOKEN');
    debugPrint('$fcmToken');
    debugPrint('========================================');
  } catch (e) {
    debugPrint('❌ FCM TOKEN ERROR: $e');
  }

  runApp(const MyApp());
}

/// =======================================================
/// NAVIGATOR KEY
/// =======================================================

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                navigatorKey: navigatorKey,

                debugShowCheckedModeBanner: false,

                title: 'Hibr & Waraq',

                theme: AppTheme.lightTheme,

                darkTheme: AppTheme.darkTheme,

                themeMode: themeMode,

                locale: localeState,

                supportedLocales: AppLocalizations.supportedLocales,

                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

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
