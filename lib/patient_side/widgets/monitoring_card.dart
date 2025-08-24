import 'package:flutter/material.dart';

class MonitoringCard extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback onRefresh;
  final List<Widget> dataWidgets;

  const MonitoringCard({
    super.key,
    required this.title,
    required this.isLoading,
    required this.onRefresh,
    required this.dataWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                  onPressed: onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(spacing: 8.0, runSpacing: 8.0, children: dataWidgets),
          ],
        ),
      ),
    );
  }
}
