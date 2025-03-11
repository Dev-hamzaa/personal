import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomeView extends StatefulWidget {
  const DoctorHomeView({super.key});

  @override
  State<DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<DoctorHomeView> {
  bool isLoading = true;
  List<dynamic> appointments = [];
  Map<String, dynamic>? doctorInfo;

  @override
  void initState() {
    super.initState();
    fetchDoctorInfo();
    fetchDoctorAppointments();
  }

  Future<void> fetchDoctorInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getString('userId');

      if (doctorId == null) {
        throw 'Doctor ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.baseUrl}api/doctor/$doctorId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            doctorInfo = responseData['data'];
          });
        }
      } else {
        throw 'Failed to fetch doctor info';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchDoctorAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getString('userId');

      if (doctorId == null) {
        throw 'Doctor ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.getAppointments}?doctor=$doctorId&'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            appointments = responseData['data'] ?? [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${Endpoints.getAppointments}/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await fetchDoctorAppointments();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment ${status} successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw responseData['message'] ??
              'Failed to update appointment status';
        }
      } else {
        throw 'Failed to update appointment status';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const Header(),

            // Fixed Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: doctorInfo?['profilePic'] != null
                        ? NetworkImage(
                            '${Endpoints.baseUrl}uploads/${doctorInfo!['profilePic'].toString().split('\\').last}',
                            headers: {
                              'Accept': '*/*',
                            },
                          )
                        : null,
                    child: doctorInfo?['profilePic'] == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Dr. ${doctorInfo?['name'] ?? 'Loading...'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(doctorInfo?['specialization'] ?? 'Loading...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable List Section
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const ClampingScrollPhysics(),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage:
                                          appointment['patientId'] != null &&
                                                  appointment['patientId']
                                                          ['profilePic'] !=
                                                      null &&
                                                  appointment['patientId']
                                                          ['profilePic']
                                                      .toString()
                                                      .isNotEmpty
                                              ? NetworkImage(
                                                  '${Endpoints.baseUrl}uploads/${appointment['patientId']['profilePic'].toString().split('\\').last}',
                                                  headers: {
                                                    'Accept': '*/*',
                                                  },
                                                )
                                              : null,
                                      child:
                                          (appointment['patientId'] == null ||
                                                  appointment['patientId']
                                                          ['profilePic'] ==
                                                      null ||
                                                  appointment['patientId']
                                                          ['profilePic']
                                                      .toString()
                                                      .isEmpty)
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.grey,
                                                )
                                              : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  appointment['patientId']
                                                          ?['name'] ??
                                                      'Unknown Patient',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: appointment[
                                                              'status'] ==
                                                          'completed'
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : appointment['status'] ==
                                                              'rejected'
                                                          ? Colors.red
                                                              .withOpacity(0.1)
                                                          : Colors.orange
                                                              .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  appointment['status']
                                                          ?.toUpperCase() ??
                                                      'PENDING',
                                                  style: TextStyle(
                                                    color: appointment[
                                                                'status'] ==
                                                            'completed'
                                                        ? Colors.green
                                                        : appointment[
                                                                    'status'] ==
                                                                'rejected'
                                                            ? Colors.red
                                                            : Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 16,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatDate(appointment[
                                                            'appointmentDate'] ??
                                                        ''),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.access_time,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    appointment['time'] ??
                                                        'Time not specified',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (appointment['status'] == 'pending')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            updateAppointmentStatus(
                                                appointment['_id'],
                                                'completed');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                          child: const Text('Mark as Complete'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateAppointmentStatus(
                                                appointment['_id'], 'rejected');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorLayout extends StatefulWidget {
  const DoctorLayout({super.key});

  @override
  State<DoctorLayout> createState() => _DoctorLayoutState();
}

class _DoctorLayoutState extends State<DoctorLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DoctorHomeView(), // Home/Appointments view
    const Center(child: Text('Settings')), // Placeholder for Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
