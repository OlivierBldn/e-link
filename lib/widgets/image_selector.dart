import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

class ImageSelector extends StatefulWidget {
  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        var a = Uint8List.fromList(_image!.readAsBytesSync());
        print(a);
      }
    });
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print(_image);
      }
    });
  }

  Future<File?> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _image = File(result.files.single.path!);
      return _image;
      // ImageService().sendImage(_image, 20, deviceId);
    } else {
      print("no selection");
    }
  }

  List<int> splitStringIntoPairs(String input) {
    List<int> pairs = [];
    for (int i = 0; i < input.length; i += 2) {
      if (i + 2 <= input.length) {
        pairs.add(int.parse(input.substring(i, i + 2), radix: 16));
      } else {
        pairs.add(int.parse(input.substring(i), radix: 16));
      }
    }
    return pairs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _image == null ? Text('No image selected.') : Image.file(_image!),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getImageFromGallery,
              child: Text('Select from Gallery'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                _getImageFromCamera();
              },
              child: Text('Take a Picture'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: getFile,
          child: Text('Select file'),
        ),
      ],
    );
  }
}
