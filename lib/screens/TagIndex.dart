import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/screens/add_device_screen.dart';
import 'package:flutter_application_1/screens/device_list_screen.dart';
import 'package:flutter_application_1/screens/template_screen.dart';
import 'package:flutter_application_1/widgets/AppSearchBar.dart';
import 'package:flutter_application_1/widgets/NavBar.dart'; // Added import for NavBar
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
            child: Column(
              children: [
                const TagCard(
                  title: 'Tag de fou',
                  available: true,
                  screenSize: 7.5,
                  resolutionX: 800,
                  resolutionY: 480,
                  colorMode: 'BWR',
                  mac: '35:38:0A:00:EC:5B',
                  battery: '100%',
                ),
                const TagCard(
                  title: 'Tag de ouf',
                  available: false,
                  screenSize: 7.5,
                  resolutionX: 800,
                  resolutionY: 480,
                  colorMode: 'BWR',
                  mac: '35:38:0A:00:EC:5B',
                  battery: '100%',
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Add a new device (starts BLE scan)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddDeviceScreen()),
                        );
                      },
                      child: const Text('Add New Device'),
                    ),
                    const SizedBox(height: 20),

                    // Known/scanned devices
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DeviceListScreen()),
                        );
                      },
                      child: const Text('Devices List'),
                    ),
                    const SizedBox(height: 20),

                    // Manage templates
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TemplateScreen()),
                        );
                      },
                      child: const Text('Manage Templates'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(
        selectedMenu: 'tags',
      ),
    );
  }
}
