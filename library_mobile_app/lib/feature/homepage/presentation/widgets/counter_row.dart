import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

Widget buildCounterRow(
  BuildContext context,
  String label,
  int value,
  Function(int) onChanged,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? AppColors.textDark : Colors.black87,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputDark : const Color(0xff3A7CA5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,

                color: isDark ? AppColors.primary : Colors.white,
              ),
              onPressed: () {
                if (value > 1) onChanged(value - 1);
              },
            ),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.textDark : Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? AppColors.primary : Colors.white,
              ),
              onPressed: () {
                onChanged(value + 1);
              },
            ),
          ],
        ),
      ),
    ],
  );
}
