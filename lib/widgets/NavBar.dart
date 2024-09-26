import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';

class NavBar extends StatelessWidget {
  final String selectedMenu;

  const NavBar({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: selectedMenu == 'tags'
                      ? AppColors.primaryColor
                      : Colors.black,
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
                ),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: selectedMenu == 'templates'
                      ? AppColors.primaryColor
                      : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              Text(
                'Templates',
                style: TextStyle(
                  color: selectedMenu == 'templates'
                      ? AppColors.primaryColor
                      : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
