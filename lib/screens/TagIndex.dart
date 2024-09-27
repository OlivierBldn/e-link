import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/providers/ble_device_provider.dart';
import 'package:flutter_application_1/widgets/AppSearchBar.dart';
import 'package:flutter_application_1/widgets/NavBar.dart';
import 'package:flutter_application_1/widgets/TagCard.dart';
import 'package:provider/provider.dart';

import '../utils/device_popup.dart';
import '../widgets/AppTitle.dart';

class TagIndex extends StatefulWidget {
  const TagIndex({super.key});

  @override
  TagIndexState createState() => TagIndexState();
}

class TagIndexState extends State<TagIndex> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isScanning = false;

  Future<void> _startScan(BleDeviceProvider bleProvider) async {
    setState(() {
      _isScanning = true;
    });
    await bleProvider.startBleScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const AppTitle(
                  blackText: 'Your ',
                  purpleText: 'Tags',
                ),
                AppSearchBar(
                  placeholder: 'Please enter a tag name or MAC',
                  searchController: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                Padding(padding: const EdgeInsets.only(left: 40.0, right: 40), child :
                  ElevatedButton(
                    onPressed: () {
                      _startScan(bleProvider);
                    },
                    child: const Text('Scan for Devices'),
                  ),
                ),
                _isScanning
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Consumer<BleDeviceProvider>(
                        builder: (context, provider, child) {
                          final filteredDevices =
                              provider.devices.where((device) {
                            return device.name
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ||
                                device.mac
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (filteredDevices.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('No matching devices found.'),
                              ),
                            );
                          }
                          return Padding(padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: filteredDevices.map((device) {
                            
                              return TagCard(
                                title: device.name.isEmpty
                                    ? 'Unknown Device'
                                    : device.name,
                                available: provider.isConnected &&
                                    device.mac == provider.connectedDevice?.mac,
                                screenSize: 7.5,
                                resolutionX: 800,
                                resolutionY: 480,
                                colorMode: 'BWR',
                                mac: device.mac,
                                battery: '${device.battery}%',
                                onTap: () {
                                  showDeviceOptions(context, device.mac);
                                },
                              );
                            }).toList(),
                          ),
                          );
                        },
                      ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: NavBar(selectedMenu: 'tags'),
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
