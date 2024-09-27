import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AuthorizationService {
  Future<void> checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.bluetoothScan.isDenied) {
        await Permission.bluetoothScan.request();
      }
      if (await Permission.bluetoothConnect.isDenied) {
        await Permission.bluetoothConnect.request();
      }
      if (await Permission.location.isDenied) {
        await Permission.location.request();
      }
    }
  }
}