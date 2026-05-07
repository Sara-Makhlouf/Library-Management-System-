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
            child: Column(
              children: [
                DrawerHeader(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                            'assets/images/2bab8519fbca535669c22065061978be.jpg',
                          ), // صورة المستخدم
                        ),
                        SizedBox(height: 10),
                        Text(
                          'ghufran@gmail.com',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xff81C3D7), // اللون الداخلي
                    borderRadius: BorderRadius.circular(12), // الحواف المستديرة
                    border: Border.all(
                      color: Color(0xff3A7CA5), // لون الإطار الخارجي
                      width: 2, // سمك الإطار
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                Container(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xff81C3D7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xff3A7CA5), width: 2),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
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
            Container(
              color: AppColors.background,
              height: 250,
              child: SliderWidget(),
            ),
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
