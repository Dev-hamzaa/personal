import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/views/patient/rescheduleAppointment.dart';

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
          await fetchPatientAppointments();
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

  Future<void> _showRescheduleDialog(Map<String, dynamic> appointment) async {
    DateTime selectedDate = DateTime.now();
    List<String> availableTimeSlots = [];
    List<String> bookedTimeSlots = [];
    String? selectedTimeSlot;
    bool isLoading = true;
    Map<String, dynamic> doctorDetails = {};

    // Fetch doctor details first
    try {
      final response = await http.get(
        Uri.parse(
            '${Endpoints.getDoctorDetails}/${appointment['doctorId']['_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          doctorDetails = responseData['data'];
        }
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
    }

    // Generate time slots based on doctor's schedule
    List<String> generateTimeSlots(String startTime, String endTime) {
      List<String> slots = [];
      List<String> startParts = startTime.split(' ');
      List<String> endParts = endTime.split(' ');

      List<String> startTimeParts = startParts[0].split(':');
      int startHour = int.parse(startTimeParts[0]);
      int startMinute = int.parse(startTimeParts[1]);
      bool startIsPM = startParts[1] == 'PM';

      List<String> endTimeParts = endParts[0].split(':');
      int endHour = int.parse(endTimeParts[0]);
      int endMinute = int.parse(endTimeParts[1]);
      bool endIsPM = endParts[1] == 'PM';

      if (startIsPM && startHour != 12) startHour += 12;
      if (!startIsPM && startHour == 12) startHour = 0;

      if (endIsPM && endHour != 12) endHour += 12;
      if (!endIsPM && endHour == 12) endHour = 0;

      if (endHour < startHour) {
        endHour += 24;
      }

      int currentHour = startHour;
      while (currentHour < endHour) {
        int displayHour = currentHour % 24;
        String period = displayHour >= 12 ? 'PM' : 'AM';
        if (displayHour > 12) displayHour -= 12;
        if (displayHour == 0) displayHour = 12;

        String slot = '${displayHour.toString().padLeft(2, '0')}:00 $period';
        slots.add(slot);
        currentHour++;
      }

      return slots;
    }

    // Get available time slots for selected day
    void updateAvailableTimeSlots() {
      if (doctorDetails['weeklySchedule'] == null) {
        availableTimeSlots = [];
        return;
      }

      String selectedDayName = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][selectedDate.weekday - 1];

      var schedule = (doctorDetails['weeklySchedule'] as List).firstWhere(
        (schedule) => schedule['day'] == selectedDayName,
        orElse: () => null,
      );

      if (schedule != null) {
        availableTimeSlots = generateTimeSlots(
          schedule['start'],
          schedule['end'],
        );
      } else {
        availableTimeSlots = [];
      }
    }

    // Check existing appointments for selected date
    Future<void> checkExistingAppointments() async {
      try {
        String formattedDate =
            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

        final response = await http.get(
          Uri.parse(
              '${Endpoints.getAppointments}?doctor=${appointment['doctorId']['_id']}&date=$formattedDate'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            List<dynamic> appointments = responseData['data'] ?? [];
            bookedTimeSlots = appointments
                .where((apt) =>
                    apt['_id'] !=
                    appointment['_id']) // Exclude current appointment
                .map((apt) => apt['time'] as String)
                .toList();
          }
        }
      } catch (e) {
        print('Error checking existing appointments: $e');
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reschedule Appointment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Select Date'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            updateAvailableTimeSlots();
                          });
                          await checkExistingAppointments();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (availableTimeSlots.isNotEmpty) ...[
                      const Text(
                        'Available Time Slots',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 40,
                        ),
                        itemCount: availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final timeSlot = availableTimeSlots[index];
                          final isSelected = timeSlot == selectedTimeSlot;
                          final isBooked = bookedTimeSlots.contains(timeSlot);

                          return Material(
                            color: isBooked
                                ? Colors.grey[400]
                                : isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: isBooked
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedTimeSlot = timeSlot;
                                      });
                                    },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  timeSlot,
                                  style: TextStyle(
                                    color: isBooked
                                        ? Colors.white70
                                        : isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No available time slots for this day',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedTimeSlot == null
                      ? null
                      : () async {
                          try {
                            final formattedDate =
                                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

                            final response = await http.patch(
                              Uri.parse(
                                  '${Endpoints.getAppointments}/${appointment['_id']}'),
                              headers: {
                                'Content-Type': 'application/json',
                              },
                              body: json.encode({
                                'appointmentDate': formattedDate,
                                'time': selectedTimeSlot,
                              }),
                            );

                            if (response.statusCode == 200) {
                              final responseData = json.decode(response.body);
                              if (responseData['success'] == true) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  await fetchPatientAppointments();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Appointment rescheduled successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                throw responseData['message'] ??
                                    'Failed to reschedule appointment';
                              }
                            } else {
                              throw 'Failed to reschedule appointment';
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: const Text('Reschedule'),
                ),
              ],
            );
          },
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: appointment['status'] == 'completed'
                                        ? Colors.green.withOpacity(0.1)
                                        : appointment['status'] == 'rejected'
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    appointment['status']?.toUpperCase() ??
                                        'PENDING',
                                    style: TextStyle(
                                      color: appointment['status'] ==
                                              'completed'
                                          ? Colors.green
                                          : appointment['status'] == 'rejected'
                                              ? Colors.red
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (appointment['status'] == 'rejected')
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showCancelConfirmation(
                                            appointment['_id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  )
                                else if (appointment['status'] != 'completed')
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showCancelConfirmation(
                                                appointment['_id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RescheduleAppointmentScreen(
                                                  appointment: appointment,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              await fetchPatientAppointments();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                          child: const Text('Reschedule'),
                                        ),
                                      ),
                                    ],
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
