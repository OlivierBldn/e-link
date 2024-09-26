import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart' as fb;
import 'package:flutter_application_1/providers/ble_device_provider.dart';
import 'package:flutter_application_1/screens/device_detail_screen.dart';
import 'package:provider/provider.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String _scanResult = "No scan yet";

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await fb.FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, fb.ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      final formattedResult = barcodeScanRes.replaceAllMapped(
        RegExp(r".{2}"),
        (match) => "${match.group(0)}:",
      );
      _scanResult = formattedResult.substring(0, formattedResult.length - 1);
    });

    final bleProvider = Provider.of<BleDeviceProvider>(context, listen: false);

    // Essayer de se connecter à l'appareil scanné
    try {
      

      print(_scanResult);
      await bleProvider.connectToDevice(_scanResult);

      // Attendre que la connexion soit établie avant de naviguer
      if (bleProvider.isConnected) {
        print('Connected to the device with ID: $_scanResult');
        // Naviguer vers l'écran DeviceDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceDetailScreen(deviceId: _scanResult),
          ),
        );
      } else {
        print('Failed to connect to the device.');
      }
    } catch (e) {
      print('Error during device connection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: scanBarcodeNormal,
              child: const Text("Start Barcode Scan"),
            ),
            const SizedBox(height: 20),
            Text("Scan Result: $_scanResult"),
          ],
        ),
      ),
    );
  }
}