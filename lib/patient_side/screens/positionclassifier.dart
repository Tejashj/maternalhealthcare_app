import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';


class FetalPositionClassifier extends StatefulWidget {
  @override
  _FetalPositionClassifierState createState() => _FetalPositionClassifierState();
}

class _FetalPositionClassifierState extends State<FetalPositionClassifier> {
  Interpreter? _interpreter;
  File? _modelFile;
  File? _imageFile;
  String _result = '';
  bool _isLoading = false;
  String _modelStatus = 'No model loaded';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // Upload TFLite model
  Future<void> _uploadModel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['tflite'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _modelFile = File(result.files.single.path!);
          _modelStatus = 'Loading model...';
        });

        await _loadModel();
      }
    } catch (e) {
      setState(() {
        _modelStatus = 'Error loading model: $e';
      });
    }
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      if (_modelFile != null) {
        _interpreter?.close();
        _interpreter = await Interpreter.fromFile(_modelFile!);
        
        setState(() {
          _modelStatus = 'Model loaded successfully';
        });
        
        // Print model input/output details for debugging
        print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
        print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      }
    } catch (e) {
      setState(() {
        _modelStatus = 'Error loading model: $e';
      });
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _result = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Preprocess image for model input
  Float32List _preprocessImage(File imageFile) {
    // Read and decode image
    final imageBytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Resize image to model input size (assuming 224x224, adjust as needed)
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    
    // Convert to Float32List and normalize
    Float32List input = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;
    
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);
        
        // Normalize pixel values to [0, 1] or [-1, 1] depending on your model
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }
    
    return input;
  }

  // Run inference
  Future<void> _classifyImage() async {
    if (_interpreter == null) {
      setState(() {
        _result = 'Please load a model first';
      });
      return;
    }

    if (_imageFile == null) {
      setState(() {
        _result = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Preprocess image
      Float32List input = _preprocessImage(_imageFile!);
      
      // Reshape input for the model [1, 224, 224, 3]
      var inputTensor = input.reshape([1, 224, 224, 3]);
      
      // Prepare output tensor
      var outputTensor = Float32List(2).reshape([1, 2]); // Assuming binary classification
      
      // Run inference
      _interpreter!.run(inputTensor, outputTensor);
      
      // Process results
      List<double> probabilities = outputTensor[0].cast<double>();
      
      // Determine prediction
      String prediction;
      double confidence;
      
      if (probabilities[0] > probabilities[1]) {
        prediction = 'Upright Position';
        confidence = probabilities[0];
      } else {
        prediction = 'Breech Position';
        confidence = probabilities[1];
      }
      
      setState(() {
        _result = '$prediction\nConfidence: ${(confidence * 100).toStringAsFixed(1)}%';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _result = 'Error during classification: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetal Position Classifier'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Model Upload Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model Upload',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _modelStatus,
                      style: TextStyle(
                        color: _modelStatus.contains('successfully') 
                            ? Colors.green 
                            : _modelStatus.contains('Error') 
                                ? Colors.red 
                                : Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _uploadModel,
                      icon: Icon(Icons.upload_file),
                      label: Text('Upload TFLite Model'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Image Upload Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Upload',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icon(Icons.photo_library),
                            label: Text('Gallery'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icon(Icons.camera_alt),
                            label: Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Image Preview
            if (_imageFile != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Image',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // Classification Button
            ElevatedButton.icon(
              onPressed: (_interpreter != null && _imageFile != null && !_isLoading)
                  ? _classifyImage
                  : null,
              icon: _isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.analytics),
              label: Text(_isLoading ? 'Classifying...' : 'Classify Fetal Position'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Results Section
            if (_result.isNotEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classification Result',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _result.contains('Upright') 
                              ? Colors.green[50] 
                              : Colors.orange[50],
                          border: Border.all(
                            color: _result.contains('Upright') 
                                ? Colors.green 
                                : Colors.orange,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _result,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _result.contains('Upright') 
                                ? Colors.green[800] 
                                : Colors.orange[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // Instructions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. First, upload your trained TFLite model (.tflite file)\n'
                      '2. Select an ultrasound image from gallery or take a photo\n'
                      '3. Tap "Classify Fetal Position" to get the prediction\n'
                      '4. The app will show whether the fetal position is upright or breech\n\n'
                      'Note: This is for educational purposes. Always consult with medical professionals for actual diagnosis.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative simplified preprocessing if the above doesn't work with your model
class ImageProcessor {
  static Float32List preprocessImageSimple(File imageFile, {int inputSize = 224}) {
    final imageBytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Resize and convert to grayscale if needed
    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
    
    // For grayscale model (1 channel)
    Float32List input = Float32List(1 * inputSize * inputSize * 1);
    int pixelIndex = 0;
    
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);
        // Convert to grayscale and normalize
        double gray = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
        input[pixelIndex++] = gray;
      }
    }
    
    return input;
  }
}