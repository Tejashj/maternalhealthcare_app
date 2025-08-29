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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      print("Speech recognition not available on this device.");
    }
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
    // Check for greetings and casual messages
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
      return '''You are a pregnancy nutrition and exercise assistant. The user just greeted you. 
      
      Respond with a brief, warm greeting (1-2 sentences) and mention that you're here to help with pregnancy nutrition and exercise questions. Don't give long explanations unless asked specific questions.
      
      USER MESSAGE: $userMessage''';
    }

    if (casual.any((word) => lowerMessage.contains(word)) &&
        lowerMessage.length < 20) {
      return '''You are a pregnancy nutrition and exercise assistant. The user sent a casual/short message.
      
      Respond briefly and naturally (1-2 sentences). Ask how you can help with their pregnancy nutrition or exercise needs.
      
      USER MESSAGE: $userMessage''';
    }

    return '''You are a specialized pregnancy nutrition and exercise assistant. Follow these guidelines:

RESPONSE STYLE:
- Be concise and precise - no unnecessary long explanations
- For specific questions, give direct, actionable answers
- For complex topics, organize information in bullet points
- Always emphasize consulting healthcare providers for medical advice
- Stay focused on pregnancy nutrition and exercise only

EXPERTISE AREAS:
- Pregnancy nutrition requirements and meal planning
- Safe exercises during different trimesters  
- Prenatal vitamins and supplements
- Food safety during pregnancy
- Exercise modifications and precautions

USER QUESTION: $userMessage

Provide a helpful, precise response. Keep it concise unless the question specifically requires detailed information.''';
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
          'maxOutputTokens': 512, // Reduced for more concise responses
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
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
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
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.menu_book, color: Colors.black, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Nutrition & Exercise Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
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

          // Nutrition Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Nutrition Essentials',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Prenatal vitamins + 400mcg folic acid daily\n'
                  '• DHA & ARA for brain development\n'
                  '• Extra 350-450 calories (2nd & 3rd trimester)\n'
                  '• Balanced meals: protein, carbs, healthy fats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Exercise Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Safe Exercise Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Walking, swimming, prenatal yoga, Pilates\n'
                  '• Start with 5-10 minutes daily\n'
                  '• Stay hydrated, avoid jarring movements\n'
                  '• Listen to your body, consult your doctor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Always consult your healthcare provider first',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
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
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
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
      backgroundColor: Colors.white,
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
      body: Container(
        color: Colors.white,
        child: Column(
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
                                color: Colors.grey[100],
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

                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Align(
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
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isUser ? Colors.white : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message["message"]!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                  ),
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
                          style: TextStyle(color: Colors.black),
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
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.black),
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
                        color:
                            _isListening
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_off,
                          color: _isListening ? Colors.red : Colors.black,
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
                        icon: Icon(Icons.stop, color: Colors.black),
                        onPressed: _stopTtsAndClearInput,
                      ),
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
