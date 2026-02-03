import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Sos extends StatelessWidget {
  const Sos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.pink[50], // Light pink background
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS App'),
        backgroundColor: const Color.fromARGB(
          255,
          15,
          14,
          15,
        ), // Dark pink app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 240, 235, 237)!,
              const Color.fromARGB(255, 0, 0, 0)!,
            ], // Light pink gradient
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Call Ambulance Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _callAmbulance(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    backgroundColor: const Color.fromARGB(
                      255,
                      5,
                      4,
                      5,
                    ), // Dark pink button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Rounded corners
                    ),
                    elevation: 10, // Button shadow
                  ),
                  child: Text(
                    'Call Ambulance',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20), // Spacing between buttons
              // Blood Bank Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _showBloodGroupDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    backgroundColor: const Color.fromARGB(
                      255,
                      3,
                      2,
                      3,
                    ), // Dark pink button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Rounded corners
                    ),
                    elevation: 10, // Button shadow
                  ),
                  child: Text(
                    'Blood Bank',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to call the predefined ambulance number
  void _callAmbulance(BuildContext context) async {
    // Predefined ambulance phone number
    String ambulanceNumber =
        '+917892942557'; // Replace with the actual ambulance number

    // Construct the phone call URL
    String url = 'tel:$ambulanceNumber';

    // Launch the URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not make a phone call')));
    }
  }

  void _showBloodGroupDialog(BuildContext context) {
    String selectedBloodGroup = 'A+';

    // Map of blood groups to predefined phone numbers
    final Map<String, String> bloodGroupToNumber = {
      'A+': '+919481032460', // Replace with the actual number for A+
      'A-': '+917892942557', // Replace with the actual number for A-
      'B+': '+919606248727', // Replace with the actual number for B+
      'B-': '+918217748909', // Replace with the actual number for B-
      'AB+': '+919481032460', // Replace with the actual number for AB+
      'AB-': '+917892942557', // Replace with the actual number for AB-
      'O+': '+919606248727', // Replace with the actual number for O+
      'O-': '+918217748909', // Replace with the actual number for O-
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Blood Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButton<String>(
                value: selectedBloodGroup,
                onChanged: (String? newValue) {
                  selectedBloodGroup = newValue!;
                },
                items:
                    <String>[
                      'A+',
                      'A-',
                      'B+',
                      'B-',
                      'AB+',
                      'AB-',
                      'O+',
                      'O-',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send Message'),
              onPressed: () async {
                // Get the predefined phone number for the selected blood group
                String phoneNumber = bloodGroupToNumber[selectedBloodGroup]!;
                String message = 'Urgent: Need blood group $selectedBloodGroup';
                String url =
                    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch WhatsApp')),
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class BloodBankPage extends StatelessWidget {
  final String bloodGroup;

  const BloodBankPage(this.bloodGroup, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Bank'),
        backgroundColor: const Color.fromARGB(
          255,
          167,
          28,
          128,
        ), // Dark pink app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink[50]!,
              Colors.pink[100]!,
            ], // Light pink gradient
          ),
        ),
        child: Center(
          child: Text(
            'Selected Blood Group: $bloodGroup',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
