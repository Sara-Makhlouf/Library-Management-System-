import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SectionIcon(title: title, icon: icon),
      ),
    );
  }
}

class SectionIcon extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionIcon({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.secondary,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  print("$title pressed");
                },
                child: Center(child: Icon(icon, color: AppColors.textGrey)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
