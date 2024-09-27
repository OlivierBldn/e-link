// lib/providers/ble_device_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart' as app_logger;
import '../models/ble_device.dart';
import '../services/led_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


final logger = app_logger.Logger();

class BleDeviceProvider with ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();  
  final List<BleDevice> devices = [];
  LedService ledService = LedService();
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
    // Start scanning for devices
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
      // Add the device to the list if it's not already there
      if (!devices.any((d) => d.mac == device.id)) {
        devices.add(newDevice);
        notifyListeners();
      }
    }, onError: (e) {
      logger.e('Error during scanning: $e');
    });
    // Stop scanning after 10 seconds
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
    // Connect to the device
    connectionStreamSubscription = flutterReactiveBle
        .connectToDevice(id: deviceId, connectionTimeout: const Duration(seconds: 10))
        .listen((connectionState) async {
      switch (connectionState.connectionState) { // Handle connection state changes
        case DeviceConnectionState.connecting: // Connecting to the device
          connectionStatus = 'Connecting to $deviceId...';
          break;
        case DeviceConnectionState.connected: // Connected to the device
          isConnected = true;
          connectionStatus = 'Connected to $deviceId';
          connectedDevice = devices.firstWhere((d) => d.mac == deviceId);
          await _discoverDeviceServices(deviceId);
          break;
        case DeviceConnectionState.disconnecting: // Disconnecting from the device
          connectionStatus = 'Disconnecting from $deviceId...';
          break;
        case DeviceConnectionState.disconnected: // Disconnected from the device
          isConnected = false;
          connectionStatus = 'Disconnected from $deviceId';
          connectedDevice = null;
          break;
        default: // Unknown connection state
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

  // Discover services for the connected device
  Future<void> _discoverDeviceServices(String deviceId) async {
    try {
      flutterReactiveBle.discoverAllServices(deviceId);
      List<Service> deviceServices = await flutterReactiveBle.getDiscoveredServices(deviceId);
      
      await ledService.discoverLedCharacteristic(deviceId, deviceServices);

      notifyListeners();
    } catch (e) {
      logger.e('Error discovering services: $e');
    }
  }

  // Send LED command to the device
  Future<void> sendLedCommand(bool state, String deviceId) async {
    await ledService.sendLedCommand(state);
  }

  // Read LED characteristic from the device
  Future<void> readLedCharacteristic(String deviceId) async {
    await ledService.readLedCharacteristic(deviceId);
  }

  // Load custom name from SharedPreferences
  // Test this function by calling it from the UI on Android and iOS
  @override
  void dispose() {
    scanStreamSubscription?.cancel();
    connectionStreamSubscription?.cancel();
    statusStreamSubscription?.cancel();
    super.dispose();
  }

  // Save custom name to SharedPreferences
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