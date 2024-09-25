import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  // Entry point of the app, wraps the BleExample widget inside a MaterialApp.
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
  // Flutter Reactive BLE instance for BLE operations.
  final flutterReactiveBle = FlutterReactiveBle();
  // List to store discovered BLE devices.
  final List<DiscoveredDevice> devices = [];
  // Subscription to listen to scanning results.
  StreamSubscription<DiscoveredDevice>? scanStreamSubscription;
  // Subscription to listen to the connection state of the device.
  StreamSubscription<ConnectionStateUpdate>? connectionStreamSubscription;

  // Controller to handle input for searching a MAC address.
  final TextEditingController _searchController = TextEditingController();
  // Variable to store the MAC address search key.
  String searchMacKey = '';
  // State variables to track the connection process.
  bool isConnecting = false;
  bool isConnected = false;
  // Stores the current connection status message.
  String connectionStatus = '';

  @override
  void dispose() {
    // Clean up: cancel subscriptions and dispose of the controller.
    scanStreamSubscription?.cancel();
    connectionStreamSubscription?.cancel();
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Method to request the necessary permissions for BLE functionality.
  Future<void> requestPermissions() async {
    // Check and request location permission.
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }

    // Check and request BLE scan permission.
    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    if (!bluetoothScanStatus.isGranted) {
      await Permission.bluetoothScan.request();
    }

    // Check and request BLE connect permission.
    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    if (!bluetoothConnectStatus.isGranted) {
      await Permission.bluetoothConnect.request();
    }

    // Check and request general Bluetooth permission.
    var bluetoothStatus = await Permission.bluetooth.status;
    if (!bluetoothStatus.isGranted) {
      await Permission.bluetooth.request();
    }
  }

  // Method to check if Bluetooth is enabled and then start scanning for BLE devices.
  void checkBluetoothAndScan() async {
    await requestPermissions(); // Ensure permissions are granted before checking Bluetooth status.
    final bluetoothStatus = flutterReactiveBle.statusStream.first;

    // If Bluetooth is ready, start scanning.
    if (await bluetoothStatus == BleStatus.ready) {
      startBleScan();
    } 
    // If Bluetooth is powered off, show a dialog asking the user to enable it.
    else if (await bluetoothStatus == BleStatus.poweredOff) {
      showBluetoothDialog();
    } 
    // For other statuses, print an error message.
    else {
      print("Bluetooth not ready or permissions not granted.");
    }
  }

  // Display a dialog that asks the user to enable Bluetooth.
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
                Navigator.of(context).pop(); // Close the dialog and let the user retry scanning.
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to start scanning for BLE devices.
  void startBleScan() {
    setState(() {
      devices.clear(); // Clear previous scan results before starting a new scan.
    });

    // Subscribe to scan results and update the devices list with discovered devices.
    scanStreamSubscription = flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.balanced)
        .listen((device) {
      // Check if the device is already in the list, if not, add it.
      if (!devices.any((d) => d.id == device.id)) {
        setState(() {
          devices.add(device);
        });
      }
    }, onError: (e) {
      // Handle scanning errors.
      print('Error occurred while scanning: $e');
    });
  }

  // Method to handle connecting to a selected BLE device.
  Future<void> connectToDevice(String deviceId) async {
    setState(() {
      isConnecting = true;
      connectionStatus = 'Connecting...'; // Update connection status to "Connecting".
    });

    // Cancel any existing connection streams.
    connectionStreamSubscription?.cancel();

    // Attempt to connect to the BLE device.
    connectionStreamSubscription = flutterReactiveBle
        .connectToDevice(id: deviceId, connectionTimeout: const Duration(seconds: 10))
        .listen((connectionState) {
      // Handle different connection states.
      switch (connectionState.connectionState) {
        case DeviceConnectionState.connecting:
          setState(() {
            connectionStatus = 'Connecting to $deviceId...'; // Update status to connecting.
          });
          break;
        case DeviceConnectionState.connected:
          setState(() {
            isConnected = true;
            connectionStatus = 'Connected to $deviceId'; // Update status to connected.
          });
          break;
        case DeviceConnectionState.disconnecting:
          setState(() {
            connectionStatus = 'Disconnecting from $deviceId...'; // Update status to disconnecting.
          });
          break;
        case DeviceConnectionState.disconnected:
          setState(() {
            isConnected = false;
            connectionStatus = 'Disconnected from $deviceId'; // Update status to disconnected.
          });
          break;
        default:
          setState(() {
            connectionStatus = 'Unknown connection state'; // Handle unexpected states.
          });
      }
    }, onError: (e) {
      // Handle connection errors.
      setState(() {
        connectionStatus = 'Error connecting to device: $e';
        isConnecting = false;
      });
    });

    setState(() {
      isConnecting = false; // Reset the connection state.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter the device list based on the search MAC key entered by the user.
    final filteredDevices = devices
        .where((device) => device.id.toLowerCase().contains(searchMacKey.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Example'),
      ),
      body: Column(
        children: [
          // TextField for entering the MAC address to filter the devices.
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
                  searchMacKey = value; // Update searchMacKey when the user types.
                });
              },
            ),
          ),
          // Button to initiate the scanning process.
          ElevatedButton(
            onPressed: () {
              checkBluetoothAndScan(); // Start scanning when button is clicked.
            },
            child: const Text('Scan for Devices'),
          ),
          // Show connection status and a loading indicator while connecting.
          if (isConnecting) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(connectionStatus),
            ),
            const CircularProgressIndicator(),
          ] 
          // If connected, show the connection status and an icon.
          else if (isConnected) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(connectionStatus),
            ),
            const Icon(Icons.bluetooth_connected, color: Colors.green),
          ] 
          // Display the list of discovered devices.
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      filteredDevices[index].name.isEmpty ? 'Unknown Device' : filteredDevices[index].name,
                    ),
                    subtitle: Text(filteredDevices[index].id),
                    onTap: () {
                      // Connect to the selected device when tapped.
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