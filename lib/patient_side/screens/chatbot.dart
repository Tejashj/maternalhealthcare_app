import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// A simple data class for a chat message
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class MedicalChatbotPage extends StatefulWidget {
  const MedicalChatbotPage({super.key});

  @override
  State<MedicalChatbotPage> createState() => _MedicalChatbotPageState();
}

class _MedicalChatbotPageState extends State<MedicalChatbotPage> {
  // --- Credentials & Config ---
  final String _apiKey = dotenv.env['GEMINI_API_KEY']!;
  final String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";

  // --- State Variables ---
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text:
            "Hello! I am your personal medical assistant. How can I help you today?",
        isUser: false,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "systemInstruction": {
            "parts": [
              {
                "text":
                    "You are a helpful and compassionate medical assistant chatbot. "
                    "Your purpose is to provide general medical information and support in a clear, easy-to-understand manner. "
                    "You are not a doctor. "
                    "** provide remedies to the problem **"
                    "*Strictly limit your response to be between 100 and 150 words.* "
                    "IMPORTANT: You MUST end every single response with the following disclaimer, exactly as written, on a new line: "
                    "'Disclaimer: I am an AI assistant and not a medical professional. Please consult a qualified healthcare provider for any medical advice, diagnosis, or treatment.'",
              },
            ],
          },
          "contents": _buildConversationHistory(userMessage),
          "generationConfig": {
            "temperature": 0.0, // Makes the output deterministic
          },
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final botResponse =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add(ChatMessage(text: botResponse, isUser: false));
        });
      } else {
        _showError(
          "Failed to get response from AI. Status code: ${response.statusCode}\nBody: ${response.body}",
        );
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildConversationHistory(String currentMessage) {
    final List<Map<String, dynamic>> contents = [];
    contents.add({
      "role": "user",
      "parts": [
        {"text": currentMessage},
      ],
    });
    return contents;
  }

  void _showError(String message) {
    setState(() {
      _messages.add(ChatMessage(text: "Error: $message", isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediBot"),
        backgroundColor: const Color.fromARGB(255, 1, 19, 17),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(
                color: Color.fromARGB(255, 9, 14, 13),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: SelectableText(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 3,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                hintText: "Ask a medical question...",
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color.fromARGB(255, 14, 16, 16),
            ),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
