import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class GenderSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const GenderSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  Widget _chip(String value, String label, IconData icon) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : (isDark ? AppColors.inputDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textDark.withOpacity(0.5)
                          : AppColors.textLight.withOpacity(0.5)),
              ),

              const SizedBox(width: 6),

              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.textDark : AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('M', 'Male', Icons.male_rounded),

        const SizedBox(width: 10),

        _chip('F', 'Female', Icons.female_rounded),
      ],
    );
  }
}
