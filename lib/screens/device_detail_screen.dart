// lib/screens/device_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_device_provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;
  // Device detail screen to control LED
  const DeviceDetailScreen({super.key, required this.deviceId});

  // Build the device detail screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control LED'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton( // Button to turn on LED
              onPressed: () {
                final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.sendLedCommand(true, deviceId);
              },
              child: const Text('Turn On LED'),
            ),
            const SizedBox(height: 20),
            ElevatedButton( // Button to turn off LED
              onPressed: () {
                final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.sendLedCommand(false, deviceId);
              },
              child: const Text('Turn Off LED'),
            ),
            const SizedBox(height: 40),
            ElevatedButton( // Button to read LED value
              onPressed: () {
                final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.readLedCharacteristic(deviceId);
              },
              child: const Text('Read LED Value'),
            ),
          ],
        ),
      ),
    );
  }
}