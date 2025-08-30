import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OvulationCalculatorPage extends StatefulWidget {
  const OvulationCalculatorPage({super.key});

  @override
  State<OvulationCalculatorPage> createState() =>
      _OvulationCalculatorPageState();
}

class _OvulationCalculatorPageState extends State<OvulationCalculatorPage> {
  DateTime? lastPeriodDate;
  int cycleLength = 28;

  // Results
  DateTime? fertileStart;
  DateTime? fertileEnd;
  DateTime? ovulationDay;
  DateTime? nextPeriod;
  DateTime? pregnancyTestDay;
  DateTime? dueDate;

  final dateFormat = DateFormat("MMMM d, yyyy");

  void calculate() {
    if (lastPeriodDate == null) return;

    ovulationDay = lastPeriodDate!.add(Duration(days: cycleLength - 14));
    fertileStart = ovulationDay!.subtract(const Duration(days: 5));
    fertileEnd = ovulationDay;
    nextPeriod = lastPeriodDate!.add(Duration(days: cycleLength));
    pregnancyTestDay = nextPeriod!.add(const Duration(days: 1));
    dueDate = lastPeriodDate!.add(const Duration(days: 280));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ovulation Calculator"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            const Text("Enter Your Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Last Period Picker
            Row(
              children: [
                const Text("Last Period: ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        lastPeriodDate = picked;
                      });
                      calculate();
                    }
                  },
                  child: Text(lastPeriodDate == null
                      ? "Pick Date"
                      : dateFormat.format(lastPeriodDate!)),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Cycle Length Input
            Row(
              children: [
                const Text("Cycle Length: ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Expanded(
                  child: Slider(
                    value: cycleLength.toDouble(),
                    min: 21,
                    max: 35,
                    divisions: 14,
                    label: "$cycleLength days",
                    onChanged: (val) {
                      setState(() {
                        cycleLength = val.toInt();
                      });
                      calculate();
                    },
                  ),
                ),
                Text("$cycleLength days"),
              ],
            ),

            const SizedBox(height: 25),

            // Results Section
            if (ovulationDay != null) ...[
              _buildInfoCard("Fertile Window",
                  "${dateFormat.format(fertileStart!)} - ${dateFormat.format(fertileEnd!)}", Colors.lightBlue),
              _buildInfoCard("Approximate Ovulation",
                  dateFormat.format(ovulationDay!), Colors.green),
              _buildInfoCard(
                  "Next Period", dateFormat.format(nextPeriod!), Colors.redAccent),
              _buildInfoCard("Pregnancy Test Day",
                  dateFormat.format(pregnancyTestDay!), Colors.orangeAccent),
              _buildInfoCard("Estimated Due Date",
                  dateFormat.format(dueDate!), Colors.purpleAccent),
            ],

            const SizedBox(height: 30),

            // About Ovulation Section
            const Text("About Ovulation",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Common signs of ovulation include:",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            _buildBulletPoint(
                "Rise in basal body temperature (0.5 to 1°F), measured with a thermometer."),
            _buildBulletPoint(
                "Higher levels of luteinizing hormone (LH), detected by a home ovulation kit."),
            _buildBulletPoint(
                "Cervical mucus may become clear, thin, and stretchy (like raw egg whites)."),
            _buildBulletPoint("Breast tenderness."),
            _buildBulletPoint("Bloating."),
            _buildBulletPoint("Spotting."),
            _buildBulletPoint("Slight pain or cramping in your side."),
          ],
        ),
      ),
    );
  }

  // Card Builder
  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  // Bullet Point Builder
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
