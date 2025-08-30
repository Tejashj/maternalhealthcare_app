import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'dart:async';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(ECGMonitorApp());
}

class ECGMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maternal Healthcare ECG Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ECGMonitorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ECGData {
  final double time;
  final double value;

  ECGData(this.time, this.value);
}

class ECGMonitorScreen extends StatefulWidget {
  @override
  _ECGMonitorScreenState createState() => _ECGMonitorScreenState();
}

class _ECGMonitorScreenState extends State<ECGMonitorScreen> {
  List<ECGData> _ecgData = [];
  int _bpm = 0;
  Timer? _dataTimer;
  Timer? _bpmTimer;
  Timer? _countdownTimer;
  Random _random = Random();
  bool _isMonitoring = false;
  int _secondsRemaining = 120; // 2 minutes
  double _averageBPM = 0.0;
  bool _monitoringComplete = false;
  bool _isConnected = false;
  String _connectionStatus = "Disconnected";

  // BPM calculation variables
  List<int> _bpmReadings = [];
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
    _dataTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
        if (_ecgData.length > 200) {
          _ecgData.removeAt(0);
        }

        double time = _ecgData.isNotEmpty ? _ecgData.last.time + 20 : 0;
        double value = _simulateECGValue(time);

        // Adjust all previous x-values to create scrolling effect
        for (var data in _ecgData) {
          data = ECGData(data.time - 20, data.value);
        }

        _ecgData.add(ECGData(time, value));
      });
    });

    // Simulate BPM updates (every 2 seconds)
    _bpmTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isMonitoring) {
        setState(() {
          // Simulate realistic BPM values
          _bpm = 65 + _random.nextInt(25);

          // Store BPM reading for averaging
          _bpmReadings.add(_bpm);
          _bpmReadingsCount++;

          // Update average BPM
          if (_bpmReadings.isNotEmpty) {
            _averageBPM =
                _bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length;
          }
        });
      } else {
        timer.cancel();
      }
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
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

  void _completeMonitoring() {
    setState(() {
      _isMonitoring = false;
      _monitoringComplete = true;

      // Calculate final average BPM from all readings
      if (_bpmReadings.isNotEmpty) {
        _averageBPM =
            _bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length;
      } else {
        // Fallback calculation if no readings available
        _averageBPM = _bpm.toDouble();
      }
    });
    _dataTimer?.cancel();
    _bpmTimer?.cancel();
  }

  double _simulateECGValue(double time) {
    // Simulate a realistic ECG waveform
    double t = time / 1000; // Convert to seconds
    double heartbeat = sin(2 * pi * t * (_bpm / 60)) * 0.8;

    // P wave
    double pWave = 0.3 * exp(-pow((t % (60.0 / _bpm) - 0.1) * 10, 2));

    // QRS complex
    double qrs = 1.5 * exp(-pow((t % (60.0 / _bpm) - 0.2) * 20, 2));

    // T wave
    double tWave = 0.5 * exp(-pow((t % (60.0 / _bpm) - 0.35) * 10, 2));

    return heartbeat + pWave + qrs + tWave + (0.1 * _random.nextDouble());
  }

  void _connectToDevice() {
    // Simulate connection process
    setState(() {
      _connectionStatus = "Connecting...";
    });

    Future.delayed(Duration(seconds: 2), () {
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Maternal Healthcare ECG Monitor'),
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
            padding: EdgeInsets.all(8),
            color: _isConnected ? Colors.green[100] : Colors.red[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
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
            padding: EdgeInsets.all(8),
            color: _monitoringComplete
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
                  color: _monitoringComplete
                      ? Colors.blue
                      : _isMonitoring
                      ? Colors.green
                      : Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  _monitoringComplete
                      ? "Monitoring Complete!"
                      : _isMonitoring
                      ? "${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} remaining"
                      : "Ready to start monitoring",
                  style: TextStyle(
                    color: _monitoringComplete
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
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
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
                  primaryXAxis: NumericAxis(
                    isVisible: false,
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
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
            child: _monitoringComplete
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
            _buildStatCard('${_bpmReadingsCount}', 'Readings', Colors.green),
          ],
        ),
        SizedBox(height: 16),
        _isMonitoring
            ? ElevatedButton(
                onPressed: () {
                  _completeMonitoring();
                },
                child: Text('Stop Monitoring'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              )
            : ElevatedButton(
                onPressed: _isConnected ? _startMonitoring : null,
                child: Text('Start 2-Minute Monitoring'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
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
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard(
              '${_averageBPM.toStringAsFixed(1)}',
              'Avg BPM',
              Colors.purple,
            ),
            _buildStatCard('2:00', 'Duration', Colors.blue),
            _buildStatCard('$_bpmReadingsCount', 'Readings', Colors.green),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "Based on $_bpmReadingsCount BPM readings",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetMonitoring,
          child: Text('Start New Monitoring'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
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
        SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey[600])),
      ],
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maternalhealthcare/config/appwrite_client.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:maternalhealthcare/patient_side/provider/patient_provider.dart';
import 'package:maternalhealthcare/role_selection.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'config/constants.dart';
import 'package:maternalhealthcare/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Appwrite
  AppwriteClient.instance.init();

  // Run the app with providers
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientDataProvider()),
        ChangeNotifierProvider(create: (_) => DoctorDataProvider()),
      ],
      child: MaterialApp(
        title: 'Health App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          fontFamily: 'Inter',
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const RoleSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
>>>>>>> a57a1d571e4bf2c5211739591e487dd0cec7da60
    );
  }
}
