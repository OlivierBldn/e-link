import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/constants/radiuses.dart';
import 'package:flutter_application_1/constants/text_sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSearchBar extends StatelessWidget {
  final String placeholder;

  const AppSearchBar({
    super.key,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 0,
      ),
      child: SizedBox(
        height: 36, // Set your desired height here
        child: TextField(
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
                fontSize: AppTextSizes.md,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: AppColors.lightGray),
            filled: true,
            fillColor: AppColors.white,
            border: const OutlineInputBorder(
              borderRadius: AppRadiuses.circle,
              borderSide: BorderSide(
                color: AppColors.lightGray,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                'assets/search.svg',
                height: 16,
                width: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF8E8E93),
                  BlendMode.modulate,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
