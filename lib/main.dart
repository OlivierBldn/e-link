// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/TagIndex.dart';
import 'package:provider/provider.dart';

import 'providers/ble_device_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BleDeviceProvider()
            ..initializeStatusListener(), // Initialize Bluetooth status listener
        ),
      ],
      child: MaterialApp(
        title: 'Flutter BLE App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const TagIndex(),
      ),
    );
  }
}
