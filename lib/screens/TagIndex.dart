import 'package:e_link_1/screens/TagCard.dart';
import 'package:flutter/material.dart';

class TagIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tags'),
      ),
      body: ListView(
        children: [
          TagCard(
            title: 'Tag 1',
            available: true,
            screenSize: 5.5,
            resolutionX: 1080,
            resolutionY: 1920,
            colorMode: 'RGB',
            mac: '00:00:00:00:00:00',
            battery: '100%',
          ),
        ],
      ),
    );
  }
}
