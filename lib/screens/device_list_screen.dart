import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_device_provider.dart';
import '../utils/device_popup.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleDeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              bleProvider.startBleScan();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              bleProvider.startBleScan();
            },
            child: const Text('Scan for Devices'),
          ),
          // Display connection status (if any)
          if (bleProvider.connectionStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(bleProvider.connectionStatus),
            ),

          // List of devices (both known and scanned)
          Expanded(
            child: ListView.builder(
              itemCount: bleProvider.devices.length,
              itemBuilder: (context, index) {
                final device = bleProvider.devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text('MAC: ${device.mac}'),
                  onTap: () {
                    // Show the popup to connect/disconnect/view details
                    showDeviceOptions(context, device.mac);
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