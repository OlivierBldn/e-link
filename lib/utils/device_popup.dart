// lib/utils/device_popup.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_device_provider.dart';
// import '../screens/device_detail_screen.dart';

/// Show a popup when the user selects a device from a list
void showDeviceOptions(BuildContext context, String deviceId) {
  final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    builder: (BuildContext ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bluetooth_connected),
            title: const Text('Connect'),
            onTap: () {
              Navigator.pop(ctx);
              bleProvider.connectToDevice(deviceId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth_disabled),
            title: const Text('Disconnect'),
            onTap: () {
              Navigator.pop(ctx);
              bleProvider.disconnectFromDevice();
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Turn On LED'),
            onTap: () {
              final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.sendLedCommand(true, deviceId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text('Turn Off LED'),
            onTap: () {
              final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.sendLedCommand(false, deviceId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_list_bulleted),
            title: const Text('Read LED Value'),
            onTap: () {
              final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);
                bleProvider.readLedCharacteristic(deviceId);
            },
          ),
        ],
      );
    },
  );
}