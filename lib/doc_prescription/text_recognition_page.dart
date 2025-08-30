import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TextRecognitionPage extends StatefulWidget {
  final String imagePath;
  const TextRecognitionPage({
    super.key,
    required this.imagePath,
    required String imageUrl,
    required bool isFromGallery,
  });

  @override
  _TextRecognitionPageState createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  String _extractedText = '';
  String _aiResponse = ''; // Stores the response from Cohere AI
  bool _isLoading = true;
  bool _isAnalyzing = false; // Track if AI analysis is in progress
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _recognizeText();
  }

  // Initialize TTS settings
  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _recognizeText() async {
    try {
      // Load the image from the file path
      final inputImage = InputImage.fromFilePath(widget.imagePath);

      // Initialize the text recognizer (supports both printed and handwritten text)
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);

      // Process the image to recognize text
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Extract and format the recognized text
      String extractedText = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          extractedText += '${line.text}\n'; // Add each line of text
        }
        extractedText +=
            '\n'; // Add an extra line break between blocks (paragraphs)
      }

      setState(() {
        _extractedText = extractedText.trim(); // Remove trailing newlines
        _isLoading = false;
      });

      // Close the text recognizer
      textRecognizer.close();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recognizing text: $e')),
      );
    }
  }

  // Function to start or stop reading text
  void _toggleReading() async {
    if (_isLoading) {
      await _flutterTts.stop(); // Stop reading
    } else {
      if (_extractedText.isNotEmpty) {
        await _flutterTts.speak(_extractedText); // Start reading
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No text to read.')),
        );
      }
    }
    setState(() {
      _isLoading = !_isLoading; // Toggle reading state
    });
  }

  // Function to analyze text using Cohere AI
  Future<void> _analyzeTextWithCohere() async {
    setState(() {
      _isAnalyzing = true; // Start analysis
    });

    try {
      final String apiKey =
          'uziKmpzc4aOCI1f2tIiUrjJGkqnPOXXpJHvc4hNv'; // Replace with your Cohere API key
      final String endpoint = 'https://api.cohere.ai/v1/generate';
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt':
              'Analyze the following text and identify possible diseases or health risks: $_extractedText',
          'max_tokens': 100, // Limit the response length
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['generations'][0]['text']; // Extract AI response
          _isAnalyzing = false; // End analysis
        });
      } else {
        setState(() {
          _aiResponse = 'Error analyzing text.';
          _isAnalyzing = false; // End analysis
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Error analyzing text: $e';
        _isAnalyzing = false; // End analysis
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100], // Light pink background
      appBar: AppBar(
        title: Text(
          'Recognized Text',
          style: TextStyle(color: Colors.white), // Brighter app bar text
        ),
        backgroundColor: Colors.pink[900], // Dark pink app bar
        actions: [
          IconButton(
            icon: Icon(
              _isLoading ? Icons.stop : Icons.play_arrow,
              color: Colors.white, // Brighter icon color
            ),
            onPressed: _toggleReading, // Toggle reading on/off
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8, // Increased shadow for a larger card effect
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Larger rounded corners
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            0.6, // 60% of screen height
                        padding:
                            const EdgeInsets.all(24.0), // Reasonable padding
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recognized Text:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.pink[900], // Brighter title color
                                ),
                              ),
                              SizedBox(
                                  height: 16), // Spacing between title and text
                              Text(
                                _extractedText.isNotEmpty
                                    ? _extractedText
                                    : 'No text recognized.',
                                textAlign:
                                    TextAlign.justify, // Justify the text
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87, // Brighter text color
                                ),
                              ),
                              SizedBox(height: 20),
                              if (_aiResponse.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Analysis:',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink[900],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      _aiResponse,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeTextWithCohere,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[900], // Dark pink button
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isAnalyzing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Analyzing...',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    )
                  : Text(
                      'Analyze with AI',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Stop TTS when the widget is disposed
    super.dispose();
  }
}
