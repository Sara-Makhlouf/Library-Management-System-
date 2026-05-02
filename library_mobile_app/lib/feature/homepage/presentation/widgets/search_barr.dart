import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: TextField(
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search Your Place",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(179, 138, 136, 136),
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
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
        /*  Container(
          decoration: BoxDecoration(
            color: const Color(0xff3A7CA5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.sort_by_alpha,
              color: Color.fromARGB(255, 17, 16, 16),
            ),
          ),
        ),*/
      ],
    );
  }
}
