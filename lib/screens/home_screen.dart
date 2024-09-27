import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/device_list_screen.dart';

import 'TagIndex.dart';
import 'add_device_screen.dart';
import 'template_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Home screen with buttons to navigate to different screens
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
                      builder: (context) => DeviceListScreen()),
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

            // mode supprimé car provoquant des problèmes de build de l'apk via la libraire 
            // Scan barcode and connect to BLE
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
            //     );
            //   },
            //   child: const Text('Scan Barcode and Connect'),
            // ),
            // const SizedBox(height: 20),

            // Tag
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TagIndex()),
                );
              },
              child: const Text('Tag index'),
            ),
          ],
        ),
      ),
    );
  }
}
