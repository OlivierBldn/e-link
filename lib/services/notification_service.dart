import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as app_logger;

final logger = app_logger.Logger();

class NotificationService {
  final FlutterReactiveBle ble;
  final String deviceId;
  QualifiedCharacteristic? notifyCharacteristic;

  NotificationService({required this.ble, required this.deviceId});

  /// Discover services and characteristics that support notifications
  Future<void> discoverServices() async {
    try {
      logger.i('Discovering services...');
      // Correct the type to List<Service>
      List<Service> services = await ble.getDiscoveredServices(deviceId);

      for (var service in services) {
        logger.i('Service found: ${service.id}');
        for (var characteristic in service.characteristics) {
          logger.i('Characteristic found: ${characteristic.id}');

          if (characteristic.isNotifiable) {
            notifyCharacteristic = QualifiedCharacteristic(
              deviceId: deviceId,
              serviceId: service.id,
              characteristicId: characteristic.id,
            );

            await startListening();
            logger.i('Subscribed to notifications for characteristic: ${characteristic.id}');
          }
        }
      }

      if (notifyCharacteristic == null) {
        logger.w('No notify characteristic found.');
      }
    } catch (e) {
      logger.e('Error discovering services: $e');
    }
  }

  /// Start listening to notifications
  Future<void> startListening() async {
    if (notifyCharacteristic != null) {
      try {
        ble.subscribeToCharacteristic(notifyCharacteristic!).listen((value) {
          logger.i('Notification received: $value');
          if (value.isNotEmpty) {
            _handleNotification(value);
          }
        });
      } catch (e) {
        logger.e('Error subscribing to notifications: $e');
      }
    }
  }

  /// Handle notifications received
  void _handleNotification(List<int> value) {
    if (value.length >= 8) {
      final Uint8List data = Uint8List.fromList(value);
      final String head = String.fromCharCodes(data.sublist(0, 3));
      final int command = data[6];
      final int parameter = data[7];

      if (head == "XTE" && command == 0x01) {
        if (parameter == 0xFF) {
          logger.i("Cache space request successful");
        } else if (parameter == 0x68) {
          logger.i("Cache space request failed");
        } else {
          logger.i("Unknown parameter value: $parameter");
        }
      }
    } else {
      logger.i("Received invalid packet length: ${value.length}");
    }
  }

  /// Interpret a detailed notification for debugging
  void interpretNotification(List<int> notification) {
    logger.i('Raw notification data: $notification');
    if (notification.length >= 12) {
      String header = String.fromCharCodes(notification.sublist(0, 3));
      int terminalType = notification[3];
      int length = notification[4];
      int checksum = notification[5];
      int command = notification[6];
      int status = notification[7];
      int controlMode = notification[8];
      int parameter = notification[9];

      logger.i('Header: $header');
      logger.i('Terminal Type: $terminalType');
      logger.i('Length: $length');
      logger.i('Checksum: $checksum');
      logger.i('Command: $command');
      logger.i('Status: ${status == 0xFF ? "Success" : "Failed"}');
      logger.i('Control Mode: ${controlMode == 0x00 ? "Get light status" : controlMode == 0x01 ? "Turn off" : "Turn on"}');
      logger.i('Parameter: $parameter');
    } else {
      logger.w('Invalid notification length');
    }
  }
}