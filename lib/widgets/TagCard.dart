import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/constants/text_sizes.dart';

class TagCard extends StatelessWidget {
  // Renamed to TagCard
  final String title;
  final bool available;
  final num screenSize;
  final num resolutionX;
  final num resolutionY;
  final String colorMode;
  final String mac;
  final String battery;

  const TagCard({
    super.key,
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
      color: AppColors.white,
      child: ListTile(
        title: Text(title),
        titleTextStyle: const TextStyle(
            fontSize: AppTextSizes.md,
            fontWeight: FontWeight.bold,
            color: AppColors.black),
        subtitle: Text('MAC: $mac, Battery: $battery'),
        trailing: Icon(
          Icons.circle,
          color: available ? AppColors.valid : AppColors.invalid,
        ),
      ),
    );
  }
}
