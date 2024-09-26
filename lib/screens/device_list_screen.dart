import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_device_provider.dart';
import '../utils/device_popup.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  DeviceListScreenState createState() => DeviceListScreenState();
}

class DeviceListScreenState extends State<DeviceListScreen> {
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleDeviceProvider>(context);

    // Filter the devices based on the search query (MAC address)
    final filteredDevices = bleProvider.devices.where((device) {
      return device.mac.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
          // Search bar for filtering devices by MAC address
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

          // List of devices (filtered by search query)
          Expanded(
            child: ListView.builder(
              itemCount: filteredDevices.length,
              itemBuilder: (context, index) {
                final device = filteredDevices[index];
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}