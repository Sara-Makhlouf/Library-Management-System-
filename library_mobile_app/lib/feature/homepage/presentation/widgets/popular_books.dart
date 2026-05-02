import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';

class PopularBooks extends StatelessWidget {
  const PopularBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.offersStatus == HomeStatus.loading) {
          return const SizedBox(
            height: 230,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state.offersStatus == HomeStatus.loaded) {
          final offersList = state.offers;

          return SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: offersList.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (BuildContext context, int index) {
                final _ = offersList[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text("ghufran"),
                  /*  child: CustomTripCard(
                    offerDescription: offer.offerDescription,
                    discountPercentage:
                        double.tryParse(offer.discountPercentage) ?? 0.0,
                  ),*/
                );
              },
            ),
          );
        } else if (state.offersStatus == HomeStatus.error) {
          return SizedBox(
            height: 230,
            child: Center(
              child: Text(
                'خطأ: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
