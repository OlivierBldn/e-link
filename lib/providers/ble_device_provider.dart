// lib/providers/ble_device_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart' as app_logger;
import '../models/ble_device.dart';
import 'package:shared_preferences/shared_preferences.dart';


final logger = app_logger.Logger();

class BleDeviceProvider with ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();  
  final List<BleDevice> devices = [];  
  StreamSubscription<DiscoveredDevice>? scanStreamSubscription;
  StreamSubscription<ConnectionStateUpdate>? connectionStreamSubscription;
  StreamSubscription<BleStatus>? statusStreamSubscription;

  bool isConnecting = false;
  bool isConnected = false;
  String connectionStatus = ''; 
  BleStatus bleStatus = BleStatus.unknown;  
  List<Service>? deviceServices;  
  BleDevice? connectedDevice;

  QualifiedCharacteristic? ledCharacteristic; // Store discovered LED characteristic
  int duration = 10; // Default LED duration

  /// Request necessary BLE and location permissions
  Future<void> requestPermissions() async {
    if (!(await Permission.location.isGranted)) {
      await Permission.location.request();
    }
    if (!(await Permission.bluetooth.isGranted)) {
      await Permission.bluetooth.request();
    }
  }

  /// Initialize BLE status listener to track Bluetooth status changes
  void initializeStatusListener() {
    statusStreamSubscription = flutterReactiveBle.statusStream.listen((status) {
      bleStatus = status;
      notifyListeners();
    }, onError: (e) {
      logger.e("Error listening to BLE status: $e");
    });
  }

  /// Check if Bluetooth is enabled
  bool isBluetoothEnabled() {
    return bleStatus == BleStatus.ready;
  }

  /// Start scanning for BLE devices (with Bluetooth check)
  Future<void> startBleScan() async {
    if (!isBluetoothEnabled()) {
      // Prompt user to enable Bluetooth if it's not on
      connectionStatus = "Please enable Bluetooth to scan for devices.";
      notifyListeners();
      return;
    }

    devices.clear();
    scanStreamSubscription?.cancel();

    scanStreamSubscription = flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.balanced)
        .listen((device) async {
      final newDevice = BleDevice(
        id: devices.length + 1,
        name: device.name.isEmpty ? 'Unknown Device' : device.name,
        customName: await loadCustomName(device.id),
        mac: device.id,
        resolution: '1080x1920',
        uuid: device.id,
        battery: 100,
      );

      if (!devices.any((d) => d.mac == device.id)) {
        devices.add(newDevice);
        notifyListeners();
      }
    }, onError: (e) {
      logger.e('Error during scanning: $e');
    });

    await Future.delayed(const Duration(seconds: 10));
    scanStreamSubscription?.cancel();
  }

  /// Connect to a BLE device by its ID (with Bluetooth check)
  Future<void> connectToDevice(String deviceId) async {
    if (!isBluetoothEnabled()) {
      // Prompt user to enable Bluetooth
      connectionStatus = "Please enable Bluetooth to connect to a device.";
      notifyListeners();
      return;
    }

    isConnecting = true;
    connectionStatus = 'Connecting...';
    notifyListeners();

    connectionStreamSubscription?.cancel();

    connectionStreamSubscription = flutterReactiveBle
        .connectToDevice(id: deviceId, connectionTimeout: const Duration(seconds: 10))
        .listen((connectionState) async {
      switch (connectionState.connectionState) {
        case DeviceConnectionState.connecting:
          connectionStatus = 'Connecting to $deviceId...';
          break;
        case DeviceConnectionState.connected:
          isConnected = true;
          connectionStatus = 'Connected to $deviceId';
          connectedDevice = devices.firstWhere((d) => d.mac == deviceId);
          await _discoverDeviceServices(deviceId);
          break;
        case DeviceConnectionState.disconnecting:
          connectionStatus = 'Disconnecting from $deviceId...';
          break;
        case DeviceConnectionState.disconnected:
          isConnected = false;
          connectionStatus = 'Disconnected from $deviceId';
          connectedDevice = null;
          break;
        default:
          connectionStatus = 'Unknown connection state';
      }
      notifyListeners();
    }, onError: (e) {
      logger.e('Error connecting to device: $e');
      isConnecting = false;
      notifyListeners();
    });

    isConnecting = false;
    notifyListeners();
  }

  /// Disconnect from the current device
  Future<void> disconnectFromDevice() async {
    if (connectedDevice == null) return;

    connectionStreamSubscription?.cancel();
    isConnected = false;
    connectedDevice = null;
    connectionStatus = 'Disconnected from device';
    notifyListeners();
  }

  /// Discover services and characteristics of the connected device
  Future<void> _discoverDeviceServices(String deviceId) async {
    try {
      flutterReactiveBle.discoverAllServices(deviceId);
      deviceServices = await flutterReactiveBle.getDiscoveredServices(deviceId);

      for (var service in deviceServices!) {
        logger.i('Discovered service: ${service.id}');
        for (var characteristic in service.characteristics) {
          logger.i('Discovered characteristic: ${characteristic.id}');
          
          if (service.id.toString() == '00002760-08c2-11e1-9073-0e8ac72e1001' && characteristic.id.toString() == '00002760-08c2-11e1-9073-0e8ac72e0001') {
            ledCharacteristic = QualifiedCharacteristic(
              deviceId: deviceId,
              serviceId: service.id,
              characteristicId: characteristic.id,
            );
            logger.i('LED characteristic found and assigned.');
          }
        }
      }
      notifyListeners();
    } catch (e) {
      logger.e('Error discovering services: $e');
    }
  }

  String selectedColor = 'Red';

  /// Build the command to control the LED
  List<int> buildLightControlCommand(bool state) {
    List<int> command = [
      0x58, 0x54, 0x45, // "XTE" ASCII
      0x01, // Terminal type
      0x0B, // Packet length (from command to last parameter)
      0x0B, // Light control command
      state ? 0x02 : 0x01, // Control mode (0x02 for turn on, 0x01 for turn off)
      getColorCode(selectedColor), // Light control type
      (duration >> 8) & 0xFF, // Duration (MSB)
      duration & 0xFF, // Duration (LSB)
    ];

    // Calculate checksum
    int checksum = 0;
    for (int i = 5; i < command.length; i++) {
      checksum += command[i];
    }
    command.insert(5, checksum & 0xFF);
    logger.i('Checksum calculated: ${checksum & 0xFF}');

    return command;
  }

  /// Return color code based on input color string
  int getColorCode(String color) {
    switch (color) {
      case 'Red':
        return 0x01;
      case 'Green':
        return 0x02;
      case 'Blue':
        return 0x03;
      case 'Yellow':
        return 0x04;
      case 'Purple':
        return 0x05;
      case 'Cyan':
        return 0x06;
      case 'White':
        return 0x07;
      case 'Front light':
        return 0x08;
      default:
        return 0x01; 
    }
  }

  /// Function to read LED characteristic value dynamically with the deviceId parameter
  Future<void> readLedCharacteristic(String deviceId) async {
    try {
      QualifiedCharacteristic ledCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse("00002760-08c2-11e1-9073-0e8ac72e0001"),
        serviceId: Uuid.parse("00002760-08c2-11e1-9073-0e8ac72e1001"),
        deviceId: deviceId,
      );

      List<int> value = await flutterReactiveBle.readCharacteristic(ledCharacteristic);
      print('Read value: $value');
    } catch (e) {
      print('Error reading characteristic: $e');
    }
  }

  Future<void> sendLedCommand(bool state, String deviceId) async {
  try {
    if (ledCharacteristic != null) {
      List<int> command = buildLightControlCommand(state);
      await flutterReactiveBle.writeCharacteristicWithoutResponse(ledCharacteristic!, value: command);
      logger.i('LED command sent successfully');
    } else {
      logger.e('LED characteristic not set.');
    }
  } catch (e) {
    logger.e('Error sending LED command, retrying: $e');
    // Retry once after a short delay
    await Future.delayed(const Duration(seconds: 2));
    try {
      if (ledCharacteristic != null) {
        List<int> command = buildLightControlCommand(state);
        await flutterReactiveBle.writeCharacteristicWithoutResponse(ledCharacteristic!, value: command);
        logger.i('LED command sent successfully on retry.');
      }
    } catch (err) {
      logger.e('Retry failed: $err');
    }
  }
}

  @override
  void dispose() {
    scanStreamSubscription?.cancel();
    connectionStreamSubscription?.cancel();
    statusStreamSubscription?.cancel();
    super.dispose();
  }

  static Future<void> saveCustomName(mac, customName) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(mac, customName ?? '');
    // print('Saved: $mac -> $customName'); // Debug
  }

  void changeDeviceName(String deviceId, String newName) async {
  // Remplacez par les UUID appropriés
  await connectToDevice(deviceId).then((_) {
      _discoverDeviceServices(deviceId);
    });
  final serviceUuid = Uuid.parse('00002760-08c2-11e1-9073-0e8ac72e1001'); // UUID du service
  final characteristicUuid = Uuid.parse('00002a00-0000-1000-8000-00805f9b34fb'); // UUID de la caractéristique

  // Écrire le nouveau nom dans la caractéristique
  await flutterReactiveBle.writeCharacteristicWithResponse(
    QualifiedCharacteristic(
      characteristicId: characteristicUuid,
      serviceId: serviceUuid,
      deviceId: deviceId,
    ),
    value: newName.codeUnits,
  );
  await disconnectFromDevice();
  print('Device name changed to: $newName');
}


  // Load custom name from SharedPreferences
  static Future<String?> loadCustomName(String mac) async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(mac);

    final prefs = await SharedPreferences.getInstance();
    String? customName = prefs.getString(mac);
    print('Loaded: $mac -> $customName'); // Debug
    return customName;
  }


  
}