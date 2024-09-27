import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/constants/text_sizes.dart';
import 'package:flutter_application_1/widgets/Pill.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      child: Flex(
        direction: Axis.vertical,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color:
                              available ? AppColors.valid : AppColors.invalid,
                        ),
                        const SizedBox(width: 4),
                        Title(
                          color: AppColors.black,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: AppTextSizes.md,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Pill(
                              text: '$screenSize"',
                            ),
                            const SizedBox(width: 4),
                            Pill(
                              text: "${resolutionX}x$resolutionY",
                            ),
                            const SizedBox(width: 4),
                            Pill(
                              text: colorMode,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: SvgPicture.asset('assets/historic.svg',
                            height: 25, color: AppColors.black),
                        onPressed: () {
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                      IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: SvgPicture.asset('assets/update.svg',
                            height: 30, color: AppColors.black),
                        onPressed: () {
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                      IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: SvgPicture.asset('assets/edit-image-icon.svg',
                            height: 20, width: 20, color: AppColors.black),
                        onPressed: () {
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Text('MAC: $mac',
                    style: const TextStyle(
                        fontSize: AppTextSizes.sm, color: AppColors.lightGray)),
                const SizedBox(width: 8),
                Text('Battery: $battery',
                    style: const TextStyle(
                      fontSize: AppTextSizes.sm,
                      color: AppColors.lightGray, // Corrected color reference
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
