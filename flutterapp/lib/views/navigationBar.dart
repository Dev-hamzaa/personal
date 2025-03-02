import 'package:flutter/material.dart';
import 'package:flutterapp/views/profile/doctorprofileView.dart';
import 'package:flutterapp/views/profile/patientProfileView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/views/patient/pateintView.dart';
import 'package:flutterapp/views/patient/patientAppointment.dart';
import 'package:flutterapp/views/donor/donorView.dart';
import 'package:flutterapp/views/profile/donorProfileView.dart';
import 'package:flutterapp/views/doctor/doctorHomeView.dart';

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
      userRole = prefs.getString('userRole') ;
    });
    print('Current user role: $userRole');
  }

  Widget _getPage(int index) {
    if (index == 0) {
      return userRole == 'doctor' 
          ? const DoctorHomeView() 
          : userRole == 'donor'
              ? const DonorView()
              : const PatientView();

    }
    if (index == 1) {
      return userRole == 'doctor' 
          ? const DoctorProfileView() 
          : userRole == 'donor'
              ? const DonorProfileView()
              : const ProfileView();
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
