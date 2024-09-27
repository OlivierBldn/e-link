import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/radiuses.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.backgroundColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadiuses.xl,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            color: color,
          ),
        ),
      ),
    );
  }
}
