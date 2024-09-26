// lib/providers/ble_device_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart' as app_logger;
import '../models/ble_device.dart';
import '../services/led_service.dart';

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

    scanStreamSubscription = flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.balanced)
        .listen((device) {
      final newDevice = BleDevice(
        id: devices.length + 1,
        name: device.name.isEmpty ? 'Unknown Device' : device.name,
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

  Future<void> sendLedCommand(bool state, String deviceId) async {
    await ledService.sendLedCommand(state);
  }

  Future<void> readLedCharacteristic(String deviceId) async {
    await ledService.readLedCharacteristic(deviceId);
  }

  @override
  void dispose() {
    scanStreamSubscription?.cancel();
    connectionStreamSubscription?.cancel();
    statusStreamSubscription?.cancel();
    super.dispose();
  }
}