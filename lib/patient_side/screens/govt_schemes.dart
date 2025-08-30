import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Government Schemes',
    theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
    home: const GovtSchemes(),
  );
}

class GovtSchemes extends StatefulWidget {
  const GovtSchemes({super.key});

  @override
  State<GovtSchemes> createState() => _GovtSchemesState();
}

class _GovtSchemesState extends State<GovtSchemes> {
  String? selectedOption;
  int? selectedMonth;
  String? selectedResourceType;

  // Resource types and their URLs for each month
  final Map<String, Map<String, String>> pregnancyResources = {
    '1': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
    },
    '2': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
    },
    '3': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
    },
    '4': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
    },
    '5': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
    },
    '6': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '7': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '8': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'prasoothi araike':
          'https://studybizz.com/karnataka-prasoothi-araika-scheme.html',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '9': {
      'Pradhan Mantri Mathru Vandhana':
          'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      'Janani Suraksha':
          'https://www.nhm.gov.in/index1.php?lang=1&level=3&sublinkid=841&lid=309',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
      'Prasoothi Araike':
          'https://studybizz.com/karnataka-prasoothi-araika-scheme.html',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
  };

  final Map<String, Map<String, String>> infantResources = {
    '1': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '2': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
      'Janani Shishu Suraksha': 'https://www.myscheme.gov.in/schemes/jssk',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '3': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '4': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '5': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
      'thayi bhagya': 'https://www.myscheme.gov.in/schemes/thayi-bhagya',
    },
    '6': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
    '7': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
    '8': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
    '9': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
    '10': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
    '11': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
    '12': {
      'Integrated child development services scheme':
          'https://icds.gov.in/en/about-us',
      'Roshan Abhiyan': 'https://poshanabhiyaan.gov.in/ ',
      'Mathru Poorna':
          'https://yuvakanaja.in/healthfamily-welfare-dept-en/matru-poorna-scheme/',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Care Resources'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your current stage:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Pregnancy Option
            _buildOptionCard(
              title: 'Pregnancy Resources',
              description: 'I am currently pregnant',
              value: 'pregnancy',
            ),

            if (selectedOption == 'pregnancy') ...[
              const SizedBox(height: 16),
              _buildMonthSelector(max: 9, isPregnancy: true),
            ],

            const SizedBox(height: 16),

            // Infant Care Option
            _buildOptionCard(
              title: 'Infant Care Resources',
              description: 'I have already delivered my baby',
              value: 'infant',
            ),

            if (selectedOption == 'infant') ...[
              const SizedBox(height: 16),
              _buildMonthSelector(max: 12, isPregnancy: false),
            ],

            if (selectedMonth != null) ...[
              const SizedBox(height: 12),
              _buildResourceDropdown(),
              if (selectedResourceType != null) ...[
                const SizedBox(height: 16),
                _buildUrlPreview(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selectedOption == value ? Colors.pink : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        value: value,
        groupValue: selectedOption,
        onChanged: (String? value) {
          setState(() {
            selectedOption = value;
            selectedMonth = null;
            selectedResourceType = null;
          });
        },
      ),
    );
  }

  Widget _buildMonthSelector({required int max, required bool isPregnancy}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select month:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: max,
          itemBuilder: (context, index) {
            final month = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMonth = month;
                  selectedResourceType = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      selectedMonth == month
                          ? Colors.pink[100]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        selectedMonth == month
                            ? Colors.pink
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Month $month',
                    style: TextStyle(
                      fontWeight:
                          selectedMonth == month
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          selectedMonth == month
                              ? Colors.pink[800]
                              : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResourceDropdown() {
    final resources =
        selectedOption == 'pregnancy'
            ? pregnancyResources[selectedMonth.toString()]
            : infantResources[selectedMonth.toString()];

    if (resources == null || resources.isEmpty) {
      return const Text('No resources available for this month');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select resource type:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedResourceType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          items:
              resources.keys.map((String key) {
                return DropdownMenuItem<String>(value: key, child: Text(key));
              }).toList(),
          onChanged: (String? newValue) async {
            if (newValue != null && resources[newValue] != null) {
              setState(() {
                selectedResourceType = newValue;
              });
              await _launchUrl(resources[newValue]!);
            }
          },
          hint: const Text('Choose a resource'),
        ),
      ],
    );
  }

  Widget _buildUrlPreview() {
    final resources =
        selectedOption == 'pregnancy'
            ? pregnancyResources[selectedMonth.toString()]
            : infantResources[selectedMonth.toString()];

    final url = resources?[selectedResourceType];

    if (url == null) return Container();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected: $selectedResourceType',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(url, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch: $url')));
    }
  }
}
