import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.transparent,
          boxShadow: [],
        ),
        child: CarouselSlider(
          items: [
            Image.asset('lib/assets/images/photo_2026-04-22_18-20-25.jpg'),
            Image.asset('lib/assets/images/photo_2026-04-22_18-20-33.jpg'),
            Image.asset('lib/assets/images/photo_2026-04-22_18-20-40.jpg'),
          ],
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
          ),
        ),
      ),
    );
  }
}
