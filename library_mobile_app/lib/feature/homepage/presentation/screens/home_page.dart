import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/presentation/cart_screen.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/BottomNav.dart';

import 'package:library_mobile_app/feature/homepage/presentation/widgets/seaction.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/search_barr.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,
          appBar: state.tabIndex == 1
              ? AppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  actions: [
                    Container(
                      width: 50,
                      height: 50,

                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.notifications_none,
                          color: AppColors.secondary,
                          size: 30,
                        ),
                        onPressed: () {
                          print('Notifications pressed');
                        },
                      ),
                    ),
                  ],
                )
              : null,

          drawer: Drawer(
            // تغيير لون خلفية القائمة بالكامل للون البيج الفاتح جداً والمتناسق مع التطبيق
            backgroundColor: const Color(0xFFF5EFEB),
            surfaceTintColor: Colors.transparent,
            child: Column(
              children: [
                // --- قسم الـ Header (معلومات المستخدم) ---
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    // إعطاء الهيدر لون بيج دافئ ومميز لفصله عن بقية الخيارات
                    color: Color(0xFFD8C8A8),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF605232),
                    // يمكنك استبدالها بـ AssetImage مخصصة لصورة المستخدم لاحقاً
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFF5EFEB),
                    ),
                  ),
                  accountName: const Text(
                    'Ghufran Ibrahim',
                    style: TextStyle(
                      color: Color(0xFF2C2518),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: const Text(
                    'ghufran@example.com',
                    style: TextStyle(color: Color(0xFF605232), fontSize: 14),
                  ),
                ),

                // --- قسم خيارات التنقل والمكتبة ---
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.history_edu,
                          color: Color(0xFF605232),
                        ),
                        title: const Text(
                          'سجل الاستعارات',
                          style: TextStyle(
                            color: Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF605232),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF605232),
                        ),
                        title: const Text(
                          'طلباتي والتوصيل',
                          style: TextStyle(
                            color: Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF605232),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.card_giftcard,
                          color: Color(0xFF605232),
                        ),
                        title: const Text(
                          'نقاطي والمكافآت',
                          style: TextStyle(
                            color: Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF605232),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),

                      const Divider(
                        color: Color(0xFFD8C8A8),
                        thickness: 1,
                        indent: 15,
                        endIndent: 15,
                      ),

                      // --- قسم الإعدادات والدعم ---
                      ListTile(
                        leading: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF605232),
                        ),
                        title: const Text(
                          'الإعدادات',
                          style: TextStyle(
                            color: Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF605232),
                        ),
                        title: const Text(
                          'تواصل معنا',
                          style: TextStyle(
                            color: Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // --- قسم تسجيل الخروج (مثبت في الأسفل تماماً) ---
                const Divider(color: Color(0xFFD8C8A8), thickness: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xFFB33A3A),
                  ), // لون أحمر هادئ وغير صارخ
                  title: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      color: Color(0xFFB33A3A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          body: buildBody(state.tabIndex),
          bottomNavigationBar: BottomNav(
            currentIndex: state.tabIndex,
            onTap: (index) {
              context.read<HomeBloc>().add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }

  Widget buildBody(int state) {
    switch (state) {
      case 0:
        return const Center(child: Text("Favourite Page"));

      case 1:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Search(),
            ),

            SliderWidget(),

            SizedBox(height: 100, child: Section()),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "   PopularBooks",
                style: TextStyle(fontSize: 18, color: AppColors.textGrey),
              ),
            ),
            SizedBox(height: 10),
            /* Expanded(
              child: BlocProvider(
                create: (context) => OffersBloc(
                  tourRepository: TourRepository(tourApi: TourOffersApi()),
                )..getOffers(),
                child: Offers(),
              ),
            ),*/
          ],
        );
      case 2:
        return CartScreen();
      default:
        return const Center(child: Text("Home"));
    }
  }
}
