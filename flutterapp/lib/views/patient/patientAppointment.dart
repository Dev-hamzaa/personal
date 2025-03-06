import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> {
  bool isLoading = true;
  List<dynamic> appointments = [];
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    fetchPatientAppointments();
  }

  Future<void> fetchPatientAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('userId');

      if (patientId == null) {
        throw 'Patient ID not found';
      }

      print('Fetching appointments for patient: $patientId');

      final response = await http.get(
        Uri.parse('${Endpoints.getAppointments}?patient=$patientId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('\n=== Patient Appointments Response ===');
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
      print('Error fetching patient appointments: $e');
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

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      print('Cancelling appointment: $appointmentId');

      final response = await http.delete(
        Uri.parse('${Endpoints.getAppointments}/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Refresh the appointments list
          await fetchPatientAppointments();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw responseData['message'] ?? 'Failed to cancel appointment';
        }
      } else {
        throw 'Failed to cancel appointment';
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCancelConfirmation(String appointmentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cancelAppointment(appointmentId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> getFilteredAppointments() {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'upcoming':
        return appointments.where((appointment) {
          final appointmentDate =
              DateTime.parse(appointment['appointmentDate']);
          return appointmentDate.isAfter(now);
        }).toList();
      case 'past':
        return appointments.where((appointment) {
          final appointmentDate =
              DateTime.parse(appointment['appointmentDate']);
          return appointmentDate.isBefore(now);
        }).toList();
      default:
        return appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Filter options
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (String value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'upcoming',
                    child: Text('Upcoming'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'past',
                    child: Text('Past'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'all',
                    child: Text('All'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: getFilteredAppointments().length,
                  itemBuilder: (context, index) {
                    final appointment = getFilteredAppointments()[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment['doctorId'] != null
                                            ? 'Dr. ${appointment['doctorId']['name'] ?? 'Unknown'}'
                                            : 'Doctor not specified',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        appointment['doctorId'] != null
                                            ? appointment['doctorId']
                                                    ['specialization'] ??
                                                'Specialization not specified'
                                            : 'Specialization not available',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Appointment status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appointment['status'] == 'confirmed'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    appointment['status']?.toUpperCase() ??
                                        'PENDING',
                                    style: TextStyle(
                                      color:
                                          appointment['status'] == 'confirmed'
                                              ? Colors.green
                                              : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Appointment details
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(
                                      appointment['appointmentDate'] ?? ''),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  appointment['time'] ?? 'Time not specified',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Handle reschedule
                                  },
                                  child: const Text('Reschedule'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    _showCancelConfirmation(appointment['_id']);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date not specified';
    }
  }
}
