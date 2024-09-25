import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(
    title: 'BLE Example',
    home: BleExample(),
  ));
}

class BleExample extends StatefulWidget {
  const BleExample({super.key});

  @override
  _BleExampleState createState() => _BleExampleState();
}

class _BleExampleState extends State<BleExample> {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> devices = [];
  StreamSubscription<DiscoveredDevice>? scanStreamSubscription;

  final TextEditingController _searchController = TextEditingController();
  String searchMacKey = '';

  @override
  void dispose() {
    scanStreamSubscription?.cancel();
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> requestPermissions() async {
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }

    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    if (!bluetoothScanStatus.isGranted) {
      await Permission.bluetoothScan.request();
    }

    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    if (!bluetoothConnectStatus.isGranted) {
      await Permission.bluetoothConnect.request();
    }

    var bluetoothStatus = await Permission.bluetooth.status;
    if (!bluetoothStatus.isGranted) {
      await Permission.bluetooth.request();
    }
  }

  void checkBluetoothAndScan() async {
    await requestPermissions();  // Ensure permissions are granted before checking Bluetooth status
    final bluetoothStatus = flutterReactiveBle.statusStream.first;
    
    if (await bluetoothStatus == BleStatus.ready) {
      startBleScan();
    } else if (await bluetoothStatus == BleStatus.poweredOff) {
      // Show dialog to enable Bluetooth
      showBluetoothDialog();
    } else {
      print("Bluetooth not ready or permissions not granted.");
    }
  }

  void showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth is Disabled'),
          content: const Text('Please enable Bluetooth to scan for devices. Once enabled, click the button again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog and allow user to click again to retry
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void startBleScan() {
    scanStreamSubscription = flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.balanced)
        .listen((device) {
      if (!devices.any((d) => d.id == device.id)) {
        setState(() {
          devices.add(device);
        });
      }
    }, onError: (e) {
      print('Error occurred while scanning: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter the device list based on the search MAC key
    final filteredDevices = devices
        .where((device) => device.id.toLowerCase().contains(searchMacKey.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter MAC address',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchMacKey = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              checkBluetoothAndScan();
            },
            child: const Text('Scan for Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredDevices[index].name.isEmpty ? 'Unknown Device' : filteredDevices[index].name,
                  ),
                  subtitle: Text(filteredDevices[index].id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}