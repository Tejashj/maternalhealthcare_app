import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VaccineMarkerScreen extends StatefulWidget {
  const VaccineMarkerScreen({super.key});

  @override
  State<VaccineMarkerScreen> createState() => _VaccineMarkerScreenState();
}

class _VaccineMarkerScreenState extends State<VaccineMarkerScreen> {
  final Set<int> _completedVaccinations = {};
  static const String _prefsKey = 'completed_vaccinations';

  // Load completed vaccinations from SharedPreferences
  Future<void> _loadCompletedVaccinations() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList =
        prefs.getStringList(_prefsKey)?.map(int.parse).toList() ?? [];
    setState(() {
      _completedVaccinations.addAll(completedList);
    });
  }

  // Save completed vaccinations to SharedPreferences
  Future<void> _saveCompletedVaccinations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _completedVaccinations.map((e) => e.toString()).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCompletedVaccinations();
  }

  static const List<Map<String, String>> vaccinations = [
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vaccine Tracker',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: vaccinations.length,
          itemBuilder: (context, index) {
            final v = vaccinations[index];
            final isCompleted = _completedVaccinations.contains(index);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              color: isCompleted ? Colors.grey.shade100 : Colors.white,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted ? Colors.grey : Colors.black,
                  child: Icon(
                    isCompleted ? Icons.check : Icons.vaccines,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  '${v['name']} (${v['month']})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
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
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
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
                              const TextSpan(
                                text: "Description: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: v['description']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                            ),
                            children: [
                              const TextSpan(
                                text: "Cause: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: v['cause']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                            ),
                            children: [
                              const TextSpan(
                                text: "Prevention: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: v['prevention']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                if (isCompleted) {
                                  _completedVaccinations.remove(index);
                                } else {
                                  _completedVaccinations.add(index);
                                }
                              });
                              await _saveCompletedVaccinations(); // Save after each change
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isCompleted
                                          ? 'Vaccine marked as incomplete'
                                          : 'Vaccine marked as completed!',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isCompleted ? Icons.undo : Icons.check,
                              color:
                                  isCompleted
                                      ? Colors.blue[900]
                                      : Colors.green[900],
                            ),
                            label: Text(
                              isCompleted
                                  ? 'Mark as Incomplete'
                                  : 'Mark as Done',
                              style: TextStyle(
                                color:
                                    isCompleted
                                        ? Colors.blue[900]
                                        : Colors.green[900],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isCompleted
                                      ? Colors.blue.shade100
                                      : Colors.green.shade100,
                              padding: const EdgeInsets.symmetric(
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
