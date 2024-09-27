// lib/services/image_service.dart

import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as app_logger;
import 'dart:io';
import '../constants/constants.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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
            0xC9,
            0x01,
            0x00,
            0x00,
            0x04,
            0xc4
          ]);
    } catch (e) {
      print("Error allocation cache: $e");
    }

    //

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

  Future<File> convertImageToEInkFormat(File imageFile) async {
    print('convertImageToEInkFormat: Start');
    print(
        'convertImageToEInkFormat: Received imageFile path: ${imageFile.path}');

    final directory = await getTemporaryDirectory();
    print(
        'convertImageToEInkFormat: Temporary directory path: ${directory.path}');

    final targetPath = '${directory.path}/temp_eink_image.jpg';
    print(
        'convertImageToEInkFormat: Target path for compressed image: $targetPath');

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 90,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        print(
            'convertImageToEInkFormat: Compression successful, result path: ${result.path}');
        return File(result.path);
      } else {
        throw Exception('Compression failed, result is null');
      }
    } catch (e) {
      print('convertImageToEInkFormat: Error during compression: $e');
      rethrow;
    }
  }

  void sendRedImage(String deviceId) {
    final List<int> data = [
      0x58,
      0x54,
      0x45,
      0x02,
      0x04,
      0xc4,
      0x31,
      0x01,
      0x00,
      0x58,
      0x54,
      0x45,
      0x4b,
      0x00,
      0x02,
      0x35,
      0x50,
      0x00,
      0x00,
      0x03,
      0x1a,
      0x01,
      0x00,
      0x00,
      0x00,
      0x11,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x03,
      0x20,
      0x00,
      0x00,
      0x01,
      0xe0,
      0x01,
      0x00,
      0x00,
      0x02,
      0xf4,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff
    ];
    final List<int> data2 = [
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0xff,
      0x00,
      0x3c,
      0x00,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff
    ];
    final List<int> data3 = [
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff
    ];
    final List<int> data4 = [
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0xff,
      0x3c,
      0xff,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00
    ];
    final List<int> data5 = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00
    ];
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(AppConstants.appServiceId),
      characteristicId: Uuid.parse(AppConstants.appCharacteristicId),
    );
    FlutterReactiveBle()
        .writeCharacteristicWithoutResponse(characteristic, value: data);
    FlutterReactiveBle()
        .writeCharacteristicWithoutResponse(characteristic, value: data2);
    FlutterReactiveBle()
        .writeCharacteristicWithoutResponse(characteristic, value: data3);
    FlutterReactiveBle()
        .writeCharacteristicWithoutResponse(characteristic, value: data4);
    FlutterReactiveBle()
        .writeCharacteristicWithoutResponse(characteristic, value: data5);
    FlutterReactiveBle().writeCharacteristicWithoutResponse(characteristic,
        value: [0x58, 0x54, 0x45, 0x01, 0x08, 0x04, 0x04, 0x00]);
  }
}
