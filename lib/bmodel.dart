import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class BrainModel extends StatefulWidget {
  const BrainModel({super.key});

  @override
  State<BrainModel> createState() => _BrainModelState();
}

class _BrainModelState extends State<BrainModel> {
  final _imagePicker = ImagePicker();
  late File _image;
  late List _results;
  bool imageSelect = false;

  @override
  void initState() {
    super.initState();
    _image = File("assets/0 glioma.jpg");
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/brain_AI model.tflite",
        labels: "assets/brain_labels.txt"))!;
    print("Models Loading Status: ${res}");
  }

  Future imageClassification(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print('Classification results: $recognitions');
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: ListView(
        children: [
          (imageSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(_image),
                  //or try this
                  // child: (_image != null)
                  //  ? Image.file(_image)
                  //: const Icon(Icons.image, size: 100),
                )
              : Container(
                  margin: const EdgeInsets.all(10),
                  child: const Opacity(
                    opacity: 0.8,
                    child: Center(child: Text("No image Selected")),
                  )),
          SingleChildScrollView(
            child: Column(
              children: (imageSelect)
                  ? _results.map((results) {
                      return Card(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: Text(
                              "${results["brain_labels"]}-${results["accuracy"].toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.red)),
                        ),
                      );
                    }).toList()
                  : [],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Pick Image",
        child: const Icon(Icons.image),
      ),
    );
  }

  Future pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      print('Image picked successfully');
    } else {
      print('Image picking failed');
    }
    File image = File(pickedFile!.path);
    imageClassification(image);
  }
}
