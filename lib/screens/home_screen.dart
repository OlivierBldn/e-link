import 'package:flutter/material.dart';

import 'TagIndex.dart';
import 'add_device_screen.dart';
import 'device_list_screen.dart';
import 'template_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
          ],
        ),
      ),
    );
  }
}
