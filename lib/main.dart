import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import './screens/TagIndex.dart'; // Adjust the import path as necessary

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
  StreamSubscription<ConnectionStateUpdate>? connectionStreamSubscription;
  final TextEditingController _searchController = TextEditingController();
  String searchMacKey = '';
  bool isConnecting = false;
  bool isConnected = false;
  String connectionStatus = '';

  @override
  void dispose() {
    scanStreamSubscription?.cancel();
    connectionStreamSubscription?.cancel();
    _searchController.dispose();
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
    await requestPermissions();
    final bluetoothStatus = flutterReactiveBle.statusStream.first;

    if (await bluetoothStatus == BleStatus.ready) {
      startBleScan();
    } else if (await bluetoothStatus == BleStatus.poweredOff) {
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
          content: const Text(
              'Please enable Bluetooth to scan for devices. Once enabled, click the button again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void startBleScan() {
    setState(() {
      devices.clear();
    });

    scanStreamSubscription = flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((device) {
      if (!devices.any((d) => d.id == device.id)) {
        setState(() {
          devices.add(device);
        });
      }
    }, onError: (e) {
      print('Error occurred while scanning: $e');
    });
  }

  Future<void> connectToDevice(String deviceId) async {
    setState(() {
      isConnecting = true;
      connectionStatus = 'Connecting...';
    });

    connectionStreamSubscription?.cancel();

    connectionStreamSubscription = flutterReactiveBle
        .connectToDevice(
            id: deviceId, connectionTimeout: const Duration(seconds: 10))
        .listen((connectionState) {
      switch (connectionState.connectionState) {
        case DeviceConnectionState.connecting:
          setState(() {
            connectionStatus = 'Connecting to $deviceId...';
          });
          break;
        case DeviceConnectionState.connected:
          setState(() {
            isConnected = true;
            connectionStatus = 'Connected to $deviceId';
          });
          break;
        case DeviceConnectionState.disconnecting:
          setState(() {
            connectionStatus = 'Disconnecting from $deviceId...';
          });
          break;
        case DeviceConnectionState.disconnected:
          setState(() {
            isConnected = false;
            connectionStatus = 'Disconnected from $deviceId';
          });
          break;
        default:
          setState(() {
            connectionStatus = 'Unknown connection state';
          });
      }
    }, onError: (e) {
      setState(() {
        connectionStatus = 'Error connecting to device: $e';
        isConnecting = false;
      });
    });

    setState(() {
      isConnecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDevices = devices
        .where((device) =>
            device.id.toLowerCase().contains(searchMacKey.toLowerCase()))
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TagIndex()),
              );
            },
            child: const Text('Go to TagIndex'),
          ),
          if (isConnecting) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(connectionStatus),
            ),
            const CircularProgressIndicator(),
          ] else if (isConnected) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(connectionStatus),
            ),
            const Icon(Icons.bluetooth_connected, color: Colors.green),
          ] else
            Expanded(
              child: ListView.builder(
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      filteredDevices[index].name.isEmpty
                          ? 'Unknown Device'
                          : filteredDevices[index].name,
                    ),
                    subtitle: Text(filteredDevices[index].id),
                    onTap: () {
                      connectToDevice(filteredDevices[index].id);
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
