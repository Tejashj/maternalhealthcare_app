import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'doctor_profile.dart';
import 'patient_dashboard.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    PatientsDashboardScreen(),
    AppointmentsScreen(),
    DoctorProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Black background
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.grid_view_outlined,
              color: Colors.white,
            ), // White icon
            activeIcon: Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
            ), // White active icon
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
            ), // White icon
            activeIcon: Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
            ), // White active icon
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.white), // White icon
            activeIcon: Icon(
              Icons.person_rounded,
              color: Colors.white,
            ), // White active icon
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white, // White selected label
        unselectedItemColor: Colors.grey[400], // Light grey unselected label
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
