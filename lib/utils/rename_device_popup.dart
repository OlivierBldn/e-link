import 'package:flutter/material.dart';
import '../models/ble_device.dart';
import '../providers/ble_device_provider.dart';

void showRenameDialog(BuildContext context, BleDevice device) {
  final TextEditingController nameController = TextEditingController(text: device.customName);
  // Show a dialog to rename the device
  // The dialog will have a text field to enter the new name
  // Need to be tested
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter device name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update the custom name for the device
              device.customName = nameController.text;
              final bleDeviceProvider = BleDeviceProvider();
              bleDeviceProvider.changeDeviceName(device.mac, nameController.text); // Sauvegarde le nom personnalisé
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}