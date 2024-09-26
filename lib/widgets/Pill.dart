import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/CustomButton.dart';

class Pill extends StatelessWidget {
  const Pill({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Text Input Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Text Input Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: '7.5"',
                backgroundColor: Colors.grey[600]!,
                width: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
