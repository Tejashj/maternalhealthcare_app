import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'features_dashboard.dart';
import 'health_records.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedIndex = 1;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    FeaturesDashboardScreen(),
    HealthRecordsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Black background
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.analytics_outlined,
              color: Colors.white,
            ), // White icon
            activeIcon: Icon(
              Icons.analytics_rounded,
              color: Colors.white,
            ), // White active icon
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined, color: Colors.white), // White icon
            activeIcon: Icon(
              Icons.apps_rounded,
              color: Colors.white,
            ), // White active icon
            label: 'Features',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.folder_copy_outlined,
              color: Colors.white,
            ), // White icon
            activeIcon: Icon(
              Icons.folder_copy_rounded,
              color: Colors.white,
            ), // White active icon
            label: 'Records',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white, // White selected label
        unselectedItemColor: Colors.grey[400], // Light grey unselected label
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
