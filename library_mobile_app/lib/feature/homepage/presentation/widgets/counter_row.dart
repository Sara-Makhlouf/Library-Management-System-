import 'package:flutter/material.dart';

Widget buildCounterRow(String label, int value, Function(int) onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 16)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xff3A7CA5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () {
                if (value > 1) onChanged(value - 1);
              },
            ),
            Text(
              "$value",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
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
