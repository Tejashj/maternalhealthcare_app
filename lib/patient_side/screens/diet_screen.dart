import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Data model remains the same
class DietSuggestion {
  final String name;
  final String quantity;
  final String description;
  DietSuggestion({
    required this.name,
    required this.quantity,
    required this.description,
  });

  // Factory constructor to create a DietSuggestion from JSON
  factory DietSuggestion.fromJson(Map<String, dynamic> json) {
    return DietSuggestion(
      name: json['name'] ?? 'No Name',
      quantity: json['quantity'] ?? 'N/A',
      description: json['description'] ?? 'No description available.',
    );
  }
}

class PatientDietScreen extends StatefulWidget {
  const PatientDietScreen({super.key});

  @override
  State<PatientDietScreen> createState() => _PatientDietScreenState();
}

class _PatientDietScreenState extends State<PatientDietScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  List<DietSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _monthController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // --- Main Logic to Get Diet Suggestions ---
  Future<void> _getDietSuggestions() async {
    if (_formKey.currentState!.validate()) {
      final int month = int.tryParse(_monthController.text) ?? 0;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _suggestions = [];
      });

      try {
        final fetchedSuggestions = await _fetchSuggestionsFromGemini(month);
        setState(() {
          _suggestions = fetchedSuggestions;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Error: ${e.toString()}";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }

      FocusScope.of(context).unfocus();
    }
  }

  /// Fetches diet suggestions from the Gemini API.
  Future<List<DietSuggestion>> _fetchSuggestionsFromGemini(int month) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('API Key not found in .env file');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey',
    );

    // The prompt is engineered to request a specific JSON format
    final String prompt = '''
    You are a pregnancy nutrition expert. Your knowledge is based STRICTLY on guidelines from healthychildren.org (American Academy of Pediatrics).
    For month $month of pregnancy, provide 5 distinct dietary suggestions focusing on key nutrients for that stage.
    Respond ONLY with a valid JSON array of objects. Do not include any other text, explanations, or markdown formatting like ```json.
    Each object must have three string keys: "name", "quantity", and "description".
    ''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        // Adding generation config to ask for JSON output
        'generationConfig': {"responseMimeType": "application/json"},
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final textContent =
          responseBody['candidates'][0]['content']['parts'][0]['text'];
      final List<dynamic> jsonList = jsonDecode(textContent);

      return jsonList.map((json) => DietSuggestion.fromJson(json)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'Failed to load suggestions: ${errorBody['error']['message']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- MODIFIED HERE ---
        title: Text(
          'Pregnancy Diet Guide',
          style: GoogleFonts.quicksand(
            color: Colors.white,
          ), // Set text color to white
        ),
        backgroundColor: Colors.black, // Set background to black
        iconTheme: const IconThemeData(
          color: Colors.white, // Ensure the back arrow is white
        ),
        // --- END OF MODIFICATION ---
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputForm(),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_suggestions.isNotEmpty) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---
  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Tell Us About Your Pregnancy",
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _monthController,
              decoration: const InputDecoration(
                labelText: 'Current Month of Pregnancy (1-9)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a month';
                }
                final month = int.tryParse(value);
                if (month == null || month < 1 || month > 9) {
                  return 'Please enter a valid month (1-9)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Pre-Pregnancy Weight (in kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter your weight'
                          : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _getDietSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Get Suggestions',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Daily Suggestions",
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.pink[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Text(
            '⚠ Disclaimer: These AI-generated suggestions are for informational purposes. Always consult your healthcare provider for personalized medical advice.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: Colors.amber[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            return _buildSuggestionCard(_suggestions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(DietSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.pink.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.name,
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Recommended: ${suggestion.quantity}",
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 20, thickness: 0.5),
            Text(
              suggestion.description,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
