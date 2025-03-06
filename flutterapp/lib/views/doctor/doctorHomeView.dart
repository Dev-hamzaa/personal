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

      print('Fetching doctor info for ID: $doctorId');

      final response = await http.get(
        Uri.parse('${Endpoints.getDoctorDetails}/$doctorId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('\n=== Doctor Info Response ===');
        print('Success: ${responseData['success']}');
        print('Message: ${responseData['message']}');
        print('Data: ${json.encode(responseData['data'])}');
        print('=====================================\n');

        if (responseData['success'] == true) {
          setState(() {
            doctorInfo = responseData['data'];
          });
        }
      }
    } catch (e) {
      print('Error fetching doctor info: $e');
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

      // Get today's date in YYYY-MM-DD format
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      print(
          'Fetching appointments for doctor: $doctorId on date: $formattedDate');

      final response = await http.get(
        Uri.parse('${Endpoints.getAppointments}?doctor=$doctorId&'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('\n=== Doctor Appointments Response ===');
        print('Success: ${responseData['success']}');
        print('Message: ${responseData['message']}');
        print('Data: ${json.encode(responseData['data'])}');
        print('=====================================\n');

        if (responseData['success'] == true) {
          setState(() {
            appointments = responseData['data'] ?? [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching doctor appointments: $e');
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

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      print('Updating appointment status: $appointmentId to $status');

      final response = await http.patch(
        Uri.parse('${Endpoints.getAppointments}/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Refresh the appointments list
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
      print('Error updating appointment status: $e');
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
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
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
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(appointment['patientId']['name'] ??
                                    'Unknown Patient'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Time: ${appointment['time']}'),
                                    Text(
                                        'Date: ${appointment['appointmentDate']}'),
                                    Text(
                                        'Reason: ${appointment['reason'] ?? 'Not specified'}'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (appointment['status'] == 'pending') ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          updateAppointmentStatus(
                                              appointment['_id'], 'accepted');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                        child: const Text('Accept'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          updateAppointmentStatus(
                                              appointment['_id'], 'declined');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                        child: const Text('Decline'),
                                      ),
                                    ] else if (appointment['status'] ==
                                        'accepted') ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          updateAppointmentStatus(
                                              appointment['_id'], 'completed');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                        child: const Text('Mark as Completed'),
                                      ),
                                    ] else if (appointment['status'] ==
                                        'completed') ...[
                                      const Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else if (appointment['status'] ==
                                        'declined') ...[
                                      const Text(
                                        'Declined',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
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
