import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/widgets/AppSearchBar.dart';
import 'package:flutter_application_1/widgets/NavBar.dart';
import 'package:flutter_application_1/widgets/TagCard.dart';

import '../widgets/AppTitle.dart';

class TagIndex extends StatelessWidget {
  const TagIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: ListView(
        children: [
          const AppTitle(
            blackText: 'Your ',
            purpleText: 'Tags',
          ),
          const AppSearchBar(
            placeholder: 'Please enter a tag name or MAC',
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 28,
              right: 28,
              top: 20,
            ),
            child: const Column(
              children: [
                TagCard(
                  title: 'Tag de fou',
                  available: true,
                  screenSize: 7.5,
                  resolutionX: 800,
                  resolutionY: 480,
                  colorMode: 'BWR',
                  mac: '35:38:0A:00:EC:5B',
                  battery: '100%',
                ),
                TagCard(
                  title: 'Tag de ouf',
                  available: false,
                  screenSize: 7.5,
                  resolutionX: 800,
                  resolutionY: 480,
                  colorMode: 'BWR',
                  mac: '35:38:0A:00:EC:5B',
                  battery: '100%',
                ),
              ],
            ),
          ),
          const NavBar(selectedMenu: 'tags')
        ],
      ),
    );
  }
}
