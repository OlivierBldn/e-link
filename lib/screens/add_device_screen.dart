// lib/screens/add_device_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_device_provider.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleDeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
      ),
      body: Column(
        children: [
          // Bluetooth status display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Bluetooth Status: ${bleProvider.bleStatus}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          
          // Button to start BLE scan
          ElevatedButton(
            onPressed: () {
              bleProvider.startBleScan();
            },
            child: const Text('Scan for Devices'),
          ),
          
          const SizedBox(height: 20),

          // List of discovered BLE devices
          Expanded(
            child: ListView.builder(
              itemCount: bleProvider.devices.length,
              itemBuilder: (context, index) {
                final device = bleProvider.devices[index];
                return ListTile(
                  title: Text(device.name.isEmpty ? 'Unknown Device' : device.name),
                  subtitle: Text('MAC: ${device.mac}'),
                  onTap: () {
                    bleProvider.connectToDevice(device.mac);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connecting to ${device.name}...')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}