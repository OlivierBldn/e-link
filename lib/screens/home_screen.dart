import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}
