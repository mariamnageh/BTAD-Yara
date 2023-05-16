import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class BrainTumorModel extends StatefulWidget {
  const BrainTumorModel({Key? key}) : super(key: key);

  @override
  _BrainTumorModelState createState() => _BrainTumorModelState();
}

class _BrainTumorModelState extends State<BrainTumorModel> {
  final _imagePicker = ImagePicker();
  late File _image;
  late List _output;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _image = File("assets/default_image.jpg");
    _loadModel().then((value) {
      setState(() {});
    });
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/brain_AI model.tflite',
      labels: 'assets/brain_labels.txt',
    );
  }

  Future<void> _classifyImage(File image) async {
    final List<dynamic>? output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _output = output!;
      _image = image;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) {
      return;
    }
    setState(() {
      _loading = true;
    });
    final File image = File(pickedFile.path);
    await _classifyImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Tumor Detector'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _output.isNotEmpty
                  ? '${_output[0]['label']}'
                  : 'Tap to select image',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
