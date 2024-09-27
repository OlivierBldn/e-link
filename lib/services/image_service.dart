// lib/services/image_service.dart

import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as app_logger;
import 'dart:io';
import '../constants/constants.dart';

final logger = app_logger.Logger();

class ImageService {
  final flutterReactiveBle = FlutterReactiveBle();

  List<int> buildImageControlCommand() {
    List<int> command = [
      /************** HEADER **************/
      0x58, 0x54, 0x45, 0x4B, // XTEK ASCII
      0x00, 0x00, 0x00, 0x00, // checksum
      0x00, 0x00, 0x00, 0x00, // file size
      0x00, //number of pictures
      0x00, 0x00, 0x00, 0x00, // image offset
      /************** BODY **************/
      0x00, 0x00, 0x00, 0x00, // X
      0x00, 0x00, 0x00, 0x00, // Y
      0x00, 0x00, 0x00, 0x00, // W
      0x00, 0x00, 0x00, 0x00, // H
      0x00, // compression method
      0x00, 0x00, 0x00, 0x00, // Valid data size
      /************** DATA **************/
    ];

    return command;
  }

  List<String> splitStringIntoPairs(String input) {
    List<String> pairs = [];
    for (int i = 0; i < input.length; i += 2) {
      if (i + 2 <= input.length) {
        pairs.add(input.substring(i, i + 2));
      } else {
        pairs.add(input.substring(i));
      }
    }
    return pairs;
  }

  void sendImage(File? rawImage, int mtu, String deviceId) {
    int offset = 0;
    int chunkSize = mtu - 3;

    //conversion de l'image en tableau de byte
    // List<int> img =
    // Uint8List imageData = Uint8List.fromList(null);

    print("MTU : ${mtu}, chunkSize : ${chunkSize}");
    var a = rawImage!.readAsBytesSync();
    Uint8List img = Uint8List.fromList(a);
    print("size: ${img.length}");

    try {
      // demande de l'espace de cache
      flutterReactiveBle.writeCharacteristicWithoutResponse(
          QualifiedCharacteristic(
            deviceId: deviceId,
            serviceId: Uuid.parse(AppConstants.appServiceId),
            characteristicId: Uuid.parse(AppConstants.appCharacteristicId),
          ),
          value: [
            0x58,
            0x54,
            0x45,
            0x01,
            0x0b,
            0xC9, // checksum
            0x01, // commande
            0x00,
            0x00,
            0x04,
            0xc4
          ]);
    } catch (e) {
      print("Error allocation cache: $e");
    }

    while (offset < img.length) {
      int end =
          (offset + chunkSize < img.length) ? offset + chunkSize : img.length;
      List<int> chunk = img.sublist(offset, end);
      print(
          "Sending chunk of size: ${chunk.length}, offset: $offset, chunk: $chunk");
      try {
        QualifiedCharacteristic characteristic = QualifiedCharacteristic(
          deviceId: deviceId,
          serviceId: Uuid.parse(AppConstants.appServiceId),
          characteristicId: Uuid.parse(AppConstants.appCharacteristicId),
        );

        // envoie chaque chunk de donnée un à un
        flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
            value: chunk);

        print("Chunk sent successfully");
      } catch (e) {
        print("Error writing chunk $offset: $e");
        break;
      }
    }
  }
}
