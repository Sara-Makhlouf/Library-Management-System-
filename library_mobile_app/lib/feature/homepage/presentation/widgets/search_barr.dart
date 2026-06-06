import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.inputDark : AppColors.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black38 : Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              textAlign: TextAlign.left,

              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Search Your Book",
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.textGrey
                      : const Color.fromARGB(179, 138, 136, 136),
                ),
                prefixIcon: Icon(
                  Icons.search,

                  color: isDark ? AppColors.primary : AppColors.textGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black38,
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              print('Sort pressed');
            },
            icon: Icon(
              Icons.sort_by_alpha,

              color: isDark ? AppColors.primary : Color(0xFF685A39),
            ),
          ),
        ),
      ],
    );
  }
}
