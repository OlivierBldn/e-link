import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/constants/radiuses.dart';
import 'package:flutter_application_1/constants/text_sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends StatelessWidget {
  final String selectedMenu;

  const NavBar({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: AppRadiuses.xl,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(70, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/tags.svg',
                    height: 32,
                    width: 32,
                    color: selectedMenu == 'tags'
                        ? AppColors.primaryColor
                        : AppColors.black,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
                Text(
                  'Tags',
                  style: TextStyle(
                    color: selectedMenu == 'tags'
                        ? AppColors.primaryColor
                        : Colors.black,
                    fontSize: AppTextSizes.md,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/template.svg',
                    height: 32,
                    width: 32,
                    color: selectedMenu == 'templates'
                        ? AppColors.primaryColor
                        : AppColors.black,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/templates');
                  },
                ),
                Text(
                  'Templates',
                  style: TextStyle(
                    color: selectedMenu == 'templates'
                        ? AppColors.primaryColor
                        : Colors.black,
                    fontSize: AppTextSizes.md,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/settings.svg',
                    height: 32,
                    width: 32,
                    color: selectedMenu == 'settings'
                        ? AppColors.primaryColor
                        : AppColors.black,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: selectedMenu == 'settings'
                        ? AppColors.primaryColor
                        : Colors.black,
                    fontSize: AppTextSizes.md,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
