import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/providers/ble_device_provider.dart';
import 'package:flutter_application_1/widgets/AppSearchBar.dart';
import 'package:flutter_application_1/widgets/NavBar.dart';
import 'package:flutter_application_1/widgets/TagCard.dart';
import 'package:provider/provider.dart';

import '../widgets/AppTitle.dart';

class TagIndex extends StatefulWidget {
  const TagIndex({super.key});

  @override
  _TagIndexState createState() => _TagIndexState();
}

class _TagIndexState extends State<TagIndex> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
    bleProvider.startBleScan();
  }

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
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by MAC Address',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 28,
              right: 28,
              top: 20,
            ),
            child: Consumer<BleDeviceProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: provider.devices.map((device) {
                    return TagCard(
                      title: device.name,
                      available: provider.isConnected && device.mac == provider.connectedDevice?.mac,
                      screenSize: 7.5,
                      resolutionX: 800,
                      resolutionY: 480,
                      colorMode: 'BWR',
                      mac: device.mac,

                      battery: '${device.battery}%',
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const NavBar(selectedMenu: 'tags')
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
