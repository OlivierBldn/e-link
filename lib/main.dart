import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ble_device_provider.dart';
import 'screens/home_screen.dart';

// import 'widgets/image_selector.dart';

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
        home: const HomeScreen(),
      ),
    );
  }
}
/*
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ImageSelector(),
      ),
    );
  }
}
*/