import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  int _bpm = 0;
  int _bpmReadingsCount = 0;
  List<int> _bpmReadings = [];
  double _averageBPM = 0.0;
  bool _isMonitoring = false;
  bool _monitoringComplete = false;
  int _elapsedSeconds = 0;

  Timer? _dataTimer;
  Timer? _bpmTimer;

  /// ✅ Start monitoring session
  void _startMonitoring() {
    setState(() {
      _bpm = 0;
      _bpmReadingsCount = 0;
      _bpmReadings.clear();
      _averageBPM = 0.0;
      _isMonitoring = true;
      _monitoringComplete = false;
      _elapsedSeconds = 0;
    });

    // Simulate BPM values every 2 seconds (replace with ESP32 values)
    _bpmTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final newBPM = 60 + (30 - (timer.tick % 60)); // demo fake BPM
      setState(() {
        _bpm = newBPM;
        _bpmReadings.add(newBPM);
        _bpmReadingsCount++;
      });
    });

    // Track session time (120s = 2 min)
    _dataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      if (_elapsedSeconds >= 120) {
        _completeMonitoring();
      }
    });
  }

  /// ✅ Complete monitoring and save ONLY final average to Supabase
  void _completeMonitoring() async {
    setState(() {
      _isMonitoring = false;
      _monitoringComplete = true;

      if (_bpmReadings.isNotEmpty) {
        _averageBPM =
            _bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length;
      } else {
        _averageBPM = _bpm.toDouble();
      }
    });

    _dataTimer?.cancel();
    _bpmTimer?.cancel();

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('vitals_monitoring').insert({
        'average_bpm': _averageBPM,
        'readings_count': _bpmReadingsCount,
        'duration_seconds': _elapsedSeconds,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ Final average saved: $_averageBPM BPM");
    } catch (e) {
      print("⚠️ Error saving data to Supabase: $e");
    }
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    _bpmTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fetal Heart Monitoring")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isMonitoring ? "Monitoring..." : "Press Start",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                "BPM: $_bpm",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (_monitoringComplete)
                Column(
                  children: [
                    const Text(
                      "✅ Monitoring Complete",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text("Average BPM: ${_averageBPM.toStringAsFixed(2)}"),
                    Text("Readings Count: $_bpmReadingsCount"),
                    Text("Duration: $_elapsedSeconds sec"),
                  ],
                ),
              const SizedBox(height: 40),
              if (!_isMonitoring && !_monitoringComplete)
                ElevatedButton(
                  onPressed: _startMonitoring,
                  child: const Text("Start Monitoring"),
                ),
              if (_isMonitoring)
                ElevatedButton(
                  onPressed: _completeMonitoring,
                  child: const Text("Stop Early"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
