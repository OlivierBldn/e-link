// lib/models/ble_device.dart

/// Moddel to represent a BLE device (Bluetooth Low Energy).
class BleDevice {
  final int id;             // ID of the device
  final String name;        // Name of the device (if available)
  final String mac;         // Mac address of the device
  final String resolution;  // Screen resolution (if available)
  final String uuid;        // UUID unique for the device
  final int battery;        // Battery percentage (if available)

  /// Constructor for the BleDevice class.
  BleDevice({
    required this.id,
    required this.name,
    required this.mac,
    required this.resolution,
    required this.uuid,
    required this.battery,
  });
}