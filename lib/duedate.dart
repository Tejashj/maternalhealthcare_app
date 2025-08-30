import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDateCalculator extends StatefulWidget {
  const DueDateCalculator({super.key});

  @override
  State<DueDateCalculator> createState() => _DueDateCalculatorState();
}

class _DueDateCalculatorState extends State<DueDateCalculator> {
  // Controller for the text field
  final TextEditingController _dateController = TextEditingController();

  // Variable to hold the calculated due date
  DateTime? _dueDate;
  // Variable to hold any error messages
  String _errorMessage = '';

  // Function to handle the date calculation
  void _calculateDueDate() {
    // Check if the field is empty
    if (_dateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a date first.';
        _dueDate = null;
      });
      return;
    }

    // Parse the selected date from the text field
    try {
      DateTime lmp = DateFormat('yyyy-MM-dd').parse(_dateController.text);

      // Apply Naegele's Rule: LMP + 7 days - 3 months + 1 year
      DateTime calculatedDueDate = DateTime(lmp.year + 1, lmp.month - 3, lmp.day + 7);

      setState(() {
        _dueDate = calculatedDueDate;
        _errorMessage = ''; // Clear any previous errors
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid date format.';
        _dueDate = null;
      });
    }
  }

  // Function to show the date picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      // Format the picked date and set it to the controller
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _dateController.text = formattedDate;
        // Clear previous results when a new date is selected
        _dueDate = null;
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Due Date Calculator'),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction Text
            const Text(
              'Enter the First Day of Your Last Menstrual Period (LMP):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Date Input Field
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'YYYY-MM-DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
                border: const OutlineInputBorder(),
              ),
              readOnly: true, // Force user to use the date picker
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),

            // Calculate Button
            Center(
              child: ElevatedButton(
                onPressed: _calculateDueDate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // Button background color
                  foregroundColor: Colors.white, // Button text color
                ),
                child: const Text('Calculate Due Date'),
              ),
            ),
            const SizedBox(height: 30),

            // Display Results or Errors
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (_dueDate != null) ...[
              Center(
                child: Text(
                  'Your Estimated Due Date is:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  // Format the due date to be more readable
                  DateFormat('EEEE, MMMM dd, yyyy').format(_dueDate!),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Key Information:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '• Pregnancy is calculated from the first day of your last period, which is about 2 weeks before you conceive.\n'
                '• This is only an estimate. Full-term pregnancy is typically between 37 and 42 weeks.\n'
                '• Always confirm with your healthcare provider.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Dispose the controller to avoid memory leaks
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}