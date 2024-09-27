// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/TagIndex.dart';
import 'package:provider/provider.dart';

import 'providers/ble_device_provider.dart';

import '../services/authorization_service.dart';

void main() {
  runApp(const MyApp());
  AuthorizationService().checkPermissions();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BleDeviceProvider()
            ..initializeStatusListener(),
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
