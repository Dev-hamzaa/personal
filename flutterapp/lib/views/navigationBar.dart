import 'package:flutter/material.dart';
import 'package:flutterapp/views/profile/doctorprofileView.dart';
import 'package:flutterapp/views/profile/patientProfileView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/views/doctor/doctorview.dart';
import 'package:flutterapp/views/patient/pateintView.dart';
import 'package:flutterapp/views/patient/patientAppointment.dart';

class Navigationbar extends StatefulWidget {
  const Navigationbar({super.key});

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  int _currentIndex = 0;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? 'patient';
    });
    print('Current user role: $userRole');
  }

  Widget _getPage(int index) {
    if (index == 0) {
      return userRole == 'doctor' ? const DoctorView() : const PatientView();
    }
    if (index == 1) {
      return userRole == 'doctor' ? const DoctorProfileView() : const ProfileView();
    }
    return userRole == 'doctor' 
        ? const Center(child: Text('Settings'))
        : const PatientAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _getPage(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(userRole == 'doctor' ? Icons.settings : Icons.calendar_today),
            label: userRole == 'doctor' ? 'Settings' : 'Appointments',
          ),
        ],
      ),
    );
  }
}
