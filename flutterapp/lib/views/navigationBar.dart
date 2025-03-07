import 'package:flutter/material.dart';
import 'package:flutterapp/views/profile/doctorprofileView.dart';
import 'package:flutterapp/views/profile/patientProfileView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/views/patient/pateintView.dart';
import 'package:flutterapp/views/patient/patientAppointment.dart';
import 'package:flutterapp/views/donor/donorView.dart';
import 'package:flutterapp/views/profile/donorProfileView.dart';
import 'package:flutterapp/views/doctor/doctorHomeView.dart';
import 'package:flutterapp/views/patient/donorListView.dart';
import 'package:flutterapp/views/patient/patientRequests.dart';

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
      userRole = prefs.getString('userRole');
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
    if (index == 2) {
      return userRole == 'donor'
          ? const DonorProfileView()
          : const PatientAppointments();
    }
    if (index == 3) {
      return const DonorListView();
    }
    if (index == 4) {
      return const PatientRequests();
    }
    return const PatientView();
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (userRole == 'patient') ...[
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism),
              label: 'Donors',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Requests',
            ),
          ] else if (userRole == 'donor') ...[
            const BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism),
              label: 'Donate',
            ),
          ],
        ],
      ),
    );
  }
}
