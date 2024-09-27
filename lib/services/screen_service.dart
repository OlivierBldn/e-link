import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../constants/constants.dart';

class ScreenService {
  void Refresh(String deviceId) {
    FlutterReactiveBle().writeCharacteristicWithoutResponse(
        QualifiedCharacteristic(
          deviceId: deviceId,
          serviceId: Uuid.parse(AppConstants.appServiceId),
          characteristicId: Uuid.parse(AppConstants.appCharacteristicId),
        ),
        value: [0x58, 0x54, 0x45, 0x01, 0x08, 0x04, 0x04, 0x00]);
  }
}
