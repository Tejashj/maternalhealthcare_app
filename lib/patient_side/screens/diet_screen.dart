import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class PatientDietScreen extends StatefulWidget {
  const PatientDietScreen({super.key});

  @override
  _PatientDietScreenState createState() => _PatientDietScreenState();
}

class _PatientDietScreenState extends State<PatientDietScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isTyping = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _showEducationContent = true;

  // Card interactions
  bool _isNutritionExpanded = false;
  bool _isExerciseExpanded = false;
  late AnimationController _nutritionController;
  late AnimationController _exerciseController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();

    _nutritionController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _exerciseController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nutritionController.dispose();
    _exerciseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeSpeech() async {
    await _speech.initialize();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({"role": "user", "message": message});
      _isTyping = true;
    });

    _scrollToBottom();

    String response = await getAIResponse(message);

    setState(() {
      messages.add({"role": "bot", "message": response});
      _isTyping = false;
    });

    _scrollToBottom();
    await _flutterTts.speak(response);
  }

  String _getSystemPrompt(String userMessage) {
    List<String> greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ];
    List<String> casual = [
      'how are you',
      'what\'s up',
      'sup',
      'thanks',
      'thank you',
      'ok',
      'okay',
    ];

    String lowerMessage = userMessage.toLowerCase().trim();

    if (greetings.any(
      (greeting) =>
          lowerMessage == greeting || lowerMessage.startsWith(greeting),
    )) {
      return '''You are a pregnancy nutrition and exercise assistant. Respond with a brief, warm greeting (1-2 sentences) and mention that you're here to help with pregnancy nutrition and exercise questions.
      
      USER MESSAGE: $userMessage''';
    }

    if (casual.any((word) => lowerMessage.contains(word)) &&
        lowerMessage.length < 20) {
      return '''You are a pregnancy nutrition and exercise assistant. Respond briefly and naturally (1-2 sentences). Ask how you can help with their pregnancy nutrition or exercise needs.
      
      USER MESSAGE: $userMessage''';
    }

    return '''You are a specialized pregnancy nutrition and exercise assistant. Be concise and precise. For specific questions, give direct, actionable answers. Always emphasize consulting healthcare providers for medical advice. Stay focused on pregnancy nutrition and exercise only.

USER QUESTION: $userMessage

Provide a helpful, precise response.''';
  }

  Future<String> getAIResponse(String userMessage) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    final String? baseUrl = dotenv.env['GEMINI_API_URL'];

    if (apiKey == null || baseUrl == null) {
      return 'API credentials not found. Please check your .env file.';
    }

    final String endpoint =
        '$baseUrl/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _getSystemPrompt(userMessage)},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 512,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      return 'Sorry, I could not fetch the response. Please try again.';
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                _controller.text = result.recognizedWords;
              });
              sendMessage(result.recognizedWords);
            }
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopTtsAndClearInput() async {
    await _flutterTts.stop();
    _controller.clear();
  }

  Widget _buildEducationContent() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nutrition & Exercise Guide',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () {
                  setState(() {
                    _showEducationContent = false;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),

          // Nutrition Card
          GestureDetector(
            onTap: () {
              setState(() {
                _isNutritionExpanded = !_isNutritionExpanded;
              });
              if (_isNutritionExpanded) {
                _nutritionController.forward();
              } else {
                _nutritionController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _nutritionController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_nutritionController.value * 3.14159),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        _nutritionController.value > 0.5
                            ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: Center(
                                child: Text(
                                  '• Prenatal vitamins + 400mcg folic acid daily\n\n'
                                  '• DHA & ARA for brain development\n\n'
                                  '• Extra 350-450 calories (2nd & 3rd trimester)\n\n'
                                  '• Balanced meals: protein, carbs, healthy fats',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                            : Center(
                              child: Text(
                                'Nutrition\nEssentials',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),

          // Exercise Card
          GestureDetector(
            onTap: () {
              setState(() {
                _isExerciseExpanded = !_isExerciseExpanded;
              });
              if (_isExerciseExpanded) {
                _exerciseController.forward();
              } else {
                _exerciseController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _exerciseController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_exerciseController.value * 3.14159),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        _exerciseController.value > 0.5
                            ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: Center(
                                child: Text(
                                  '• Walking, swimming, prenatal yoga, Pilates\n\n'
                                  '• Start with 5-10 minutes daily\n\n'
                                  '• Stay hydrated, avoid jarring movements\n\n'
                                  '• Listen to your body, consult your doctor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                            : Center(
                              child: Text(
                                'Safe Exercise\nTips',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange[300]!, width: 1),
            ),
            child: Row(
              children: [
                Text('⚠️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Always consult your healthcare provider first',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Typing...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Pregnancy Assistant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          if (!_showEducationContent)
            Container(
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.info_outline, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _showEducationContent = true;
                  });
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showEducationContent) _buildEducationContent(),
          Expanded(
            child:
                messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Ask about pregnancy nutrition\nand exercise!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Try: "What should I eat in first trimester?"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: _buildTypingIndicator(),
                          );
                        }

                        final message = messages[index];
                        bool isUser = message["role"] == "user";

                        return Align(
                          alignment:
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[100] : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isUser
                                        ? Colors.blue[300]!
                                        : Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message["message"]!,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Ask about nutrition or exercise...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (text) {
                          if (text.isNotEmpty) {
                            sendMessage(text);
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.blue[800]),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_off,
                        color:
                            _isListening ? Colors.red[700] : Colors.grey[700],
                      ),
                      onPressed: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.stop, color: Colors.grey[700]),
                      onPressed: _stopTtsAndClearInput,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
