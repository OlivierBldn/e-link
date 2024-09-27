// lib/screens/device_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_device_provider.dart';
import '../widgets/image_selector.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

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
            ElevatedButton(
              onPressed: () {
                final bleProvider =
                    Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.sendLedCommand(true, deviceId);
              },
              child: const Text('Turn On LED'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final bleProvider =
                    Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.sendLedCommand(false, deviceId);
              },
              child: const Text('Turn Off LED'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final bleProvider =
                    Provider.of<BleDeviceProvider>(context, listen: false);
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
