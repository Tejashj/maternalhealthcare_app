import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ECGData {
  final double time;
  final double value;

  ECGData(this.time, this.value);
}

class VitalsMonitoringScreen extends StatefulWidget {
  @override
  _VitalsMonitoringScreenState createState() => _VitalsMonitoringScreenState();
}

class _VitalsMonitoringScreenState extends State<VitalsMonitoringScreen> {
  List<ECGData> _ecgData = [];
  int _bpm = 0;
  Timer? _dataTimer;
  Timer? _bpmTimer;
  Timer? _countdownTimer;
  final Random _random = Random();
  bool _isMonitoring = false;
  int _secondsRemaining = 120; // 2 minutes
  double _averageBPM = 0.0;
  bool _monitoringComplete = false;
  bool _isConnected = false;
  String _connectionStatus = "Disconnected";

  // BPM calculation variables
  final List<int> _bpmReadings = [];
  int _bpmReadingsCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    _bpmTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeData() {
    _ecgData.clear();
    _bpmReadings.clear();
    _bpmReadingsCount = 0;
    for (int i = 0; i < 100; i++) {
      _ecgData.add(ECGData(i * 20, 0));
    }
  }

  void _startMonitoring() {
    setState(() {
      _isMonitoring = true;
      _secondsRemaining = 120;
      _averageBPM = 0.0;
      _monitoringComplete = false;
      _bpmReadings.clear();
      _bpmReadingsCount = 0;
    });

    // Simulate data reception
    _dataTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      setState(() {
        if (_ecgData.length > 200) {
          _ecgData.removeAt(0);
        }
        double time = _ecgData.isNotEmpty ? _ecgData.last.time + 20 : 0;
        double value = _simulateECGValue(time);
        _ecgData.add(ECGData(time, value));
      });
    });

    // Simulate BPM updates (every 2 seconds)
    _bpmTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isMonitoring) {
        if (!mounted) return;
        setState(() {
          _bpm = 65 + _random.nextInt(25);
          _bpmReadings.add(_bpm);
          _bpmReadingsCount++;
          _averageBPM =
              _bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length;
        });
      } else {
        timer.cancel();
      }
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _completeMonitoring();
          timer.cancel();
        }
      });
    });
  }

  // ✅ MODIFIED: Function is now async to handle the database call
  Future<void> _completeMonitoring() async {
    _dataTimer?.cancel();
    _bpmTimer?.cancel();

    double finalAverageBPM = 0.0;
    if (_bpmReadings.isNotEmpty) {
      finalAverageBPM =
          _bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length;
    }

    setState(() {
      _isMonitoring = false;
      _monitoringComplete = true;
      _averageBPM = finalAverageBPM;
    });

    // ✅ NEW: Call the function to save the final value to Supabase
    await _saveReadingToSupabase(finalAverageBPM);
  }

  // ✅ NEW: This function saves the data to your Supabase table
  Future<void> _saveReadingToSupabase(double avgBpm) async {
    // Prevent saving if the value is zero
    if (avgBpm == 0) return;

    try {
      await Supabase.instance.client.from('monitoring_data').insert({
        'average_bpm': avgBpm,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monitoring results saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving results: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _simulateECGValue(double time) {
    double t = time / 1000;
    double bpmFactor = _bpm > 0 ? _bpm / 60 : 1.0;
    double heartbeat = sin(2 * pi * t * bpmFactor) * 0.8;
    double pWave = 0.3 * exp(-pow((t % (1.0 / bpmFactor) - 0.1) * 10, 2));
    double qrs = 1.5 * exp(-pow((t % (1.0 / bpmFactor) - 0.2) * 20, 2));
    double tWave = 0.5 * exp(-pow((t % (1.0 / bpmFactor) - 0.35) * 10, 2));
    return heartbeat + pWave + qrs + tWave + (0.1 * _random.nextDouble());
  }

  void _connectToDevice() {
    setState(() => _connectionStatus = "Connecting...");
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _connectionStatus = "Connected to ESP32";
      });
    });
  }

  void _disconnect() {
    setState(() {
      _isConnected = false;
      _isMonitoring = false;
      _connectionStatus = "Disconnected";
    });
    _dataTimer?.cancel();
    _bpmTimer?.cancel();
    _countdownTimer?.cancel();
  }

  void _resetMonitoring() {
    setState(() {
      _monitoringComplete = false;
      _secondsRemaining = 120;
      _initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This build method remains unchanged.
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Maternal Healthcare ECG Monitor'),
        backgroundColor: Colors.purple[700],
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
            ),
            onPressed: _isConnected ? _disconnect : _connectToDevice,
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            padding: const EdgeInsets.all(8),
            color: _isConnected ? Colors.green[100] : Colors.red[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _connectionStatus,
                  style: TextStyle(
                    color: _isConnected ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Timer and status
          Container(
            padding: const EdgeInsets.all(8),
            color:
                _monitoringComplete
                    ? Colors.blue[100]
                    : _isMonitoring
                    ? Colors.green[100]
                    : Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _monitoringComplete
                      ? Icons.check_circle
                      : _isMonitoring
                      ? Icons.timer
                      : Icons.timer_off,
                  color:
                      _monitoringComplete
                          ? Colors.blue
                          : _isMonitoring
                          ? Colors.green
                          : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _monitoringComplete
                      ? "Monitoring Complete!"
                      : _isMonitoring
                      ? "${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} remaining"
                      : "Ready to start monitoring",
                  style: TextStyle(
                    color:
                        _monitoringComplete
                            ? Colors.blue[800]
                            : _isMonitoring
                            ? Colors.green[800]
                            : Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ECG Graph
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  primaryXAxis: const NumericAxis(
                    isVisible: false,
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  primaryYAxis: const NumericAxis(
                    minimum: -2.5,
                    maximum: 2.5,
                    isVisible: false,
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  series: <CartesianSeries>[
                    FastLineSeries<ECGData, double>(
                      dataSource: _ecgData,
                      xValueMapper: (ECGData data, _) => data.time,
                      yValueMapper: (ECGData data, _) => data.value,
                      color: Colors.greenAccent,
                      width: 2,
                    ),
                  ],
                  plotAreaBackgroundColor: Colors.black,
                ),
              ),
            ),
          ),

          // Results panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child:
                _monitoringComplete
                    ? _buildResultsPanel()
                    : _buildMonitoringPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringPanel() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('$_bpm', 'Current BPM', Colors.red),
            _buildStatCard('${_secondsRemaining}s', 'Time Left', Colors.blue),
            _buildStatCard('$_bpmReadingsCount', 'Readings', Colors.green),
          ],
        ),
        const SizedBox(height: 16),
        _isMonitoring
            ? ElevatedButton(
              onPressed: _completeMonitoring,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Stop Monitoring'),
            )
            : ElevatedButton(
              onPressed: _isConnected ? _startMonitoring : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start 2-Minute Monitoring'),
            ),
      ],
    );
  }

  Widget _buildResultsPanel() {
    return Column(
      children: [
        Text(
          "Monitoring Results",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple[700],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard(
              _averageBPM.toStringAsFixed(1),
              'Avg BPM',
              Colors.purple,
            ),
            _buildStatCard('2:00', 'Duration', Colors.blue),
            _buildStatCard('$_bpmReadingsCount', 'Readings', Colors.green),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Based on $_bpmReadingsCount BPM readings",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetMonitoring,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Start New Monitoring'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
