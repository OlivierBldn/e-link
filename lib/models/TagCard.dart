import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Tagcard extends StatelessWidget {
  final String title;
  final bool available;
  final num screenSize;
  final num resolutionX;
  final num resolutionY;
  final String colorMode;
  final String mac;
  final String battery;

  Tagcard({
    required this.title,
    required this.available,
    required this.screenSize,
    required this.resolutionX,
    required this.resolutionY,
    required this.colorMode,
    required this.mac,
    required this.battery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor,
      
      ),
      
    );
  }
}
