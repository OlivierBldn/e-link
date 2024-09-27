import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/constants/radiuses.dart';
import 'package:flutter_application_1/constants/text_sizes.dart';

class Pill extends StatelessWidget {
  final String text;
  const Pill({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        borderRadius: AppRadiuses.xl,
        color: AppColors.darkGray,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: AppTextSizes.sm,
        ),
      ),
    );
  }
}
