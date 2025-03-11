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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('userRole');
      print('Loading user role: $role'); // Debug print

      if (mounted) {
        setState(() {
          userRole = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user role: $e'); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userRole == null) {
      print('User role is null'); // Debug print
      return const Center(child: Text('Please login again'));
    }

    print('Current index: $_currentIndex, User role: $userRole'); // Debug print

    switch (_currentIndex) {
      case 0:
        if (userRole == 'doctor') return const DoctorHomeView();
        if (userRole == 'donor') return const DonorView();
        if (userRole == 'patient') return const PatientView();
        break;
      case 1:
        if (userRole == 'doctor') return const DoctorProfileView();
        if (userRole == 'donor') return const DonorProfileView();
        if (userRole == 'patient') return const ProfileView();
        break;
      case 2:
        if (userRole == 'patient') return const PatientAppointments();
        break;
      case 3:
        if (userRole == 'patient') return const DonorListView();
        break;
      case 4:
        if (userRole == 'patient') return const PatientRequests();
        break;
    }
    return const Center(child: Text('Invalid navigation state'));
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    if (userRole == 'patient') {
      items.addAll([
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
      ]);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: _buildBody(),
        ),
        bottomNavigationBar: !_isLoading && userRole != null
            ? BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (mounted) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                items: _buildNavigationItems(),
              )
            : null,
      ),
    );
  }
}
