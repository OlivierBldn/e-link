// lib/services/led_service.dart

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as app_logger;

final logger = app_logger.Logger();

class LedService {
  final flutterReactiveBle = FlutterReactiveBle();
  QualifiedCharacteristic? ledCharacteristic;

  int duration = 10; // Default LED duration
  String selectedColor = 'Red';

  LedService();

  /// Discover LED characteristic
  Future<void> discoverLedCharacteristic(
      String deviceId, List<Service> deviceServices) async {
    try {
      for (var service in deviceServices) {
        logger.i('Discovered service: ${service.id}');
        for (var characteristic in service.characteristics) {
          logger.i('Discovered characteristic: ${characteristic.id}');

          if (service.id.toString() == '00002760-08c2-11e1-9073-0e8ac72e1001' &&
              characteristic.id.toString() ==
                  '00002760-08c2-11e1-9073-0e8ac72e0001') {
            ledCharacteristic = QualifiedCharacteristic(
              deviceId: deviceId,
              serviceId: service.id,
              characteristicId: characteristic.id,
            );
            logger.i('LED characteristic found and assigned.');
          }
        }
      }
    } catch (e) {
      logger.e('Error discovering services: $e');
    }
  }

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

  /// Send LED command
  Future<void> sendLedCommand(bool state) async {
    try {
      if (ledCharacteristic != null) {
        List<int> command = buildLightControlCommand(state);
        await flutterReactiveBle.writeCharacteristicWithoutResponse(
            ledCharacteristic!,
            value: command);
        logger.i('LED command sent successfully');
      } else {
        logger.e('LED characteristic not set.');
      }
    } catch (e) {
      logger.e('Error sending LED command: $e');
    }
  }

  ///TO FIX
  /// Read the LED characteristic
  Future<void> readLedCharacteristic(String deviceId) async {
    try {
      if (ledCharacteristic != null) {
        List<int> value =
            await flutterReactiveBle.readCharacteristic(ledCharacteristic!);
        logger.i('Read value: $value');
      } else {
        logger.e('LED characteristic not set.');
      }
    } catch (e) {
      logger.e('Error reading LED characteristic: $e');
    }
  }
}
