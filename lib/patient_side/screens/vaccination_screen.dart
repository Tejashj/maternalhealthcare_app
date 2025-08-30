import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaccination Guide',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: VaccinationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VaccinationPage extends StatelessWidget {
  final List<Map<String, String>> vaccinations = [
    {
      'month': 'Month 1',
      'name': 'Hepatitis B (1st dose)',
      'description': 'Prevents mother-to-child transmission of Hepatitis B.',
      'cause': 'Caused by Hepatitis B virus (HBV).',
      'prevention': 'Vaccination, avoiding contact with infected blood.',
    },
    {
      'month': 'Month 2',
      'name': 'Hepatitis B (2nd dose)',
      'description': 'Second dose ensures continued protection.',
      'cause': 'Caused by Hepatitis B virus (HBV).',
      'prevention': 'Timely immunization and hygiene.',
    },
    {
      'month': 'Month 3',
      'name': 'Influenza (Flu)',
      'description': 'Protects pregnant women from seasonal flu.',
      'cause': 'Influenza virus, airborne and contagious.',
      'prevention': 'Annual vaccination, mask use, and hygiene.',
    },
    {
      'month': 'Month 4',
      'name': 'Pneumococcal Vaccine',
      'description': 'Protects against pneumonia and meningitis.',
      'cause': 'Streptococcus pneumoniae bacteria.',
      'prevention': 'Vaccination and avoiding respiratory infections.',
    },
    {
      'month': 'Month 5',
      'name': 'Meningococcal Vaccine',
      'description': 'Prevents meningitis and bloodstream infections.',
      'cause': 'Neisseria meningitidis bacteria.',
      'prevention': 'Vaccination, avoid sharing utensils, good hygiene.',
    },
    {
      'month': 'Month 6',
      'name': 'Tdap (Tetanus, Diphtheria, Pertussis)',
      'description':
          'Protects mother and baby from tetanus, diphtheria, and whooping cough.',
      'cause': 'Bacterial infections transmitted via wounds or air.',
      'prevention': 'Vaccination during every pregnancy.',
    },
    {
      'month': 'Month 7',
      'name': 'Influenza (2nd dose)',
      'description': 'Boosts flu protection in the later pregnancy stage.',
      'cause': 'Influenza virus.',
      'prevention': 'Booster flu shot, avoid sick individuals.',
    },
    {
      'month': 'Month 8',
      'name': 'Hepatitis A',
      'description':
          'Prevents foodborne liver infections especially in regions with poor sanitation.',
      'cause': 'Hepatitis A virus.',
      'prevention': 'Vaccination, safe food, and clean water.',
    },
    {
      'month': 'Month 9',
      'name': 'Hepatitis B (3rd dose)',
      'description':
          'Final dose ensures complete immunity against Hepatitis B.',
      'cause': 'Hepatitis B virus.',
      'prevention': 'Complete 3-dose vaccine series.',
    },
  ];

  void sendSMS(BuildContext context, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '7892942557', // Replace with the patient's phone number
      queryParameters: {'body': message},
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS app';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send SMS.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue.shade900),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pregnancy Vaccination Guide',
          style: TextStyle(color: Colors.blue.shade900),
        ),
        backgroundColor: Colors.orange.shade100,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: vaccinations.length,
          itemBuilder: (context, index) {
            final v = vaccinations[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              color: Colors.white.withOpacity(0.9),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade200,
                  child: Icon(Icons.vaccines, color: Colors.orange[900]),
                ),
                title: Text(
                  '${v['name']} (${v['month']})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                subtitle: Text(
                  'Tap for more info',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Curved box
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                            ),
                            children: [
                              TextSpan(
                                text: "Description: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: v['description']),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                            ),
                            children: [
                              TextSpan(
                                text: "Cause: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: v['cause']),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                            ),
                            children: [
                              TextSpan(
                                text: "Prevention: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: v['prevention']),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Send a normal SMS message to the patient
                              final msg =
                                  'Reminder: ${v['name']} is scheduled for ${v['month']}.';
                              sendSMS(context, msg);

                              // Show a confirmation message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Reminder sent successfully!'),
                                ),
                              );
                            },
                            icon: Icon(Icons.alarm),
                            label: Text(
                              'Remind Me',
                              style: TextStyle(color: Colors.orange[900]),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                              foregroundColor: Colors.orange[900],
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
