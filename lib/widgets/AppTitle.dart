import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/constants/text_sizes.dart';

class AppTitle extends StatelessWidget {
  final String blackText;
  final String purpleText;

  const AppTitle({
    super.key,
    required this.blackText,
    required this.purpleText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
        left: 30,
        bottom: 20,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: blackText,
              style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: AppTextSizes.title,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: purpleText,
              style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: AppTextSizes.title,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
