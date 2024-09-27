import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/widgets/AppSearchBar.dart';
import 'package:flutter_application_1/widgets/NavBar.dart';

import '../widgets/AppTitle.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  TemplateScreenState createState() => TemplateScreenState();
}

class TemplateScreenState extends State<TemplateScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const AppTitle(
                  blackText: 'Your ',
                  purpleText: 'Templates',
                ),
                AppSearchBar(
                  placeholder: 'Please enter a template name',
                  searchController: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
               const Align(
                  alignment: Alignment.bottomCenter,
                  child: NavBar(selectedMenu: 'templates'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}