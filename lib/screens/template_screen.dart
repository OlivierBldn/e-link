// lib/screens/template_screen.dart

import 'package:flutter/material.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Templates'),
      ),
      body: const Center(
        child: Text(
          'Template Management Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}