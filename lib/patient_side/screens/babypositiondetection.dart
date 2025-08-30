import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';

class BabyHeadClassifier extends StatefulWidget {
  const BabyHeadClassifier({super.key});

  @override
  State<BabyHeadClassifier> createState() => _BabyHeadClassifierState();
}

class _BabyHeadClassifierState extends State<BabyHeadClassifier> {
  Interpreter? _interpreter;
  File? _image;
  String _result = "No image selected";
  final ImagePicker _picker = ImagePicker();
  List<String> _labels = ["Ideal Position", "Breech Position"];
  List<String> _idealPositionVideos = [
    'assets/videos/ideal1.mp4',
    'assets/videos/ideal2.mp4',
  ];
  List<String> _breechPositionVideos = [
    'assets/videos/breech1.mp4',
    'assets/videos/breech2.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/model_unquant.tflite',
      );
      _labels = await _loadLabels('assets/labels/labels.txt');
      setState(() {
        _result = "Model Loaded Successfully!";
      });
    } catch (e) {
      print("Error loading model: $e");
      setState(() {
        _result = "Failed to load model: $e";
      });
    }
  }

  Future<List<String>> _loadLabels(String path) async {
    try {
      final data = await DefaultAssetBundle.of(context).loadString(path);
      return data.split('\n').map((e) => e.trim()).toList();
    } catch (e) {
      print("Error loading labels: $e");
      return ["Ideal Position", "Breech Position", "junk"];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        print("Selected image from gallery: ${_image!.path}");
      });
      _runModel(_image!);
    }
  }

  // Safe preprocessing to 4D tensor [1, height, width, 3]
  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Cannot decode image");

    final inputShape = _interpreter!.getInputTensor(0).shape;
    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];

    final resized = img.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
    );
    final imageBytes = resized.getBytes(); // RGBA bytes

    return [
      List.generate(inputHeight, (y) {
        return List.generate(inputWidth, (x) {
          int baseIndex = (y * resized.width + x) * 4;
          // Safety check: make sure we don’t go out of bounds
          if (baseIndex + 2 >= imageBytes.length) {
            return [0.0, 0.0, 0.0]; // fallback black pixel
          }
          return [
            imageBytes[baseIndex] / 255.0, // R
            imageBytes[baseIndex + 1] / 255.0, // G
            imageBytes[baseIndex + 2] / 255.0, // B
          ];
        });
      }),
    ];
  }

  Future<void> _runModel(File image) async {
    if (_interpreter == null) return;

    try {
      final input = _preprocessImage(image);

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List.generate(outputShape[1], (_) => 0.0),
      );

      print("Input tensor shape: ${_interpreter!.getInputTensor(0).shape}");
      print("Output tensor shape: ${_interpreter!.getOutputTensor(0).shape}");

      _interpreter!.run(input, output);

      // Safe argmax
      int predictedIndex = 0;
      double maxVal = output[0][0];
      for (int i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxVal) {
          maxVal = output[0][i];
          predictedIndex = i;
        }
      }

      setState(() {
        _result = "Prediction: ${_labels[predictedIndex]}";
      });

      // Navigate to Result Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResultPage(
                prediction: _labels[predictedIndex],
                videos:
                    predictedIndex == 0
                        ? _idealPositionVideos
                        : _breechPositionVideos,
              ),
        ),
      );
    } catch (e) {
      print("Error running model: $e");
      setState(() {
        _result = "Error running model: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baby Head Position Detector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Icon(Icons.image, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final String prediction;
  final List<String> videos;

  const ResultPage({super.key, required this.prediction, required this.videos});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  VideoPlayerController? _videoController;
  int _selectedVideoIndex = -1;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _playVideo(String videoPath) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.asset(videoPath)
      ..initialize()
          .then((_) {
            print("Video initialized successfully: $videoPath");
            setState(() {});
            _videoController!.play();
          })
          .catchError((error) {
            print("Error initializing video: $error");
            setState(() {
              _selectedVideoIndex = -1;
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Baby is in ${widget.prediction} position",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.videos.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(widget.videos[index].split('/').last),
                      onTap: () {
                        setState(() {
                          _selectedVideoIndex = index;
                          _playVideo(widget.videos[index]);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedVideoIndex != -1 &&
                _videoController != null &&
                _videoController!.value.isInitialized)
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
