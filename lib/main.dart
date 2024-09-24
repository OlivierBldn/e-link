import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleExample extends StatefulWidget {
  @override
  _BleExampleState createState() => _BleExampleState();
}

class _BleExampleState extends State<BleExample> {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> devices = [];
  StreamSubscription<DiscoveredDevice>? scanStreamSubscription;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }
  void startScan() {
    scanStreamSubscription = flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.balanced)
        .listen((device) {
      if (!devices.any((d) => d.id == device.id)) {
        setState(() {
          print('Found device: ${device.name}');
          devices.add(device);
        });
      }
    }, onError: (e) {
      print('Error occurred while scanning: $e');
    });
  }

  void connectToDevice(String deviceId) async {
    try {
      await flutterReactiveBle.connectToDevice(id: deviceId).first;
      print("Connected to device: $deviceId");
      // Ajouter des opérations de lecture/écriture ici
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  @override
  void dispose() {
    scanStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Example'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].name.isEmpty ? 'Unknown Device' : devices[index].name),
            subtitle: Text(devices[index].id),
            onTap: () => connectToDevice(devices[index].id),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'BLE Example',
    home: BleExample(),
  ));
}