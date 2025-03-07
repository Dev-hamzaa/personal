import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const RescheduleAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;
  bool isLoading = true;
  Map<String, dynamic> doctorDetails = {};
  List<String> _availableTimeSlots = [];
  List<String> _bookedTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    fetchDoctorDetails();
    checkExistingAppointments();
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
      _availableTimeSlots = [];
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
    ][_selectedDay!.weekday - 1];

    var schedule = (doctorDetails['weeklySchedule'] as List).firstWhere(
      (schedule) => schedule['day'] == selectedDayName,
      orElse: () => null,
    );

    if (schedule != null) {
      _availableTimeSlots = generateTimeSlots(
        schedule['start'],
        schedule['end'],
      );
    } else {
      _availableTimeSlots = [];
    }
  }

  Future<void> fetchDoctorDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Endpoints.getDoctorDetails}/${widget.appointment['doctorId']['_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            doctorDetails = responseData['data'];
            isLoading = false;
          });
          updateAvailableTimeSlots();
        }
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
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

  Future<void> checkExistingAppointments() async {
    try {
      String formattedDate =
          '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse(
            '${Endpoints.getAppointments}?doctor=${widget.appointment['doctorId']['_id']}&date=$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> appointments = responseData['data'] ?? [];
          setState(() {
            _bookedTimeSlots = appointments
                .where((apt) => apt['_id'] != widget.appointment['_id'])
                .map((apt) => apt['time'] as String)
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error checking existing appointments: $e');
    }
  }

  Future<void> rescheduleAppointment() async {
    try {
      final formattedDate =
          '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';

      final response = await http.patch(
        Uri.parse('${Endpoints.getAppointments}/${widget.appointment['_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'appointmentDate': formattedDate,
          'time': _selectedTimeSlot,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment rescheduled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(
              context, true); // Return true to indicate successful rescheduling
        } else {
          throw responseData['message'] ?? 'Failed to reschedule appointment';
        }
      } else {
        throw 'Failed to reschedule appointment';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Appointment'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${widget.appointment['doctorId']['name'] ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.appointment['doctorId']['specialization'] ??
                                'Specialization not specified',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calendar
                  Card(
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          _selectedDay != null && isSameDay(_selectedDay!, day),
                      onDaySelected: (selectedDay, focusedDay) async {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          updateAvailableTimeSlots();
                        });
                        await checkExistingAppointments();
                      },
                      calendarFormat: CalendarFormat.week,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontSize: 16),
                        leftChevronIcon: Icon(Icons.chevron_left, size: 20),
                        rightChevronIcon: Icon(Icons.chevron_right, size: 20),
                      ),
                      availableCalendarFormats: const {
                        CalendarFormat.week: 'Week',
                      },
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Slots
                  if (_selectedDay != null) ...[
                    if (_availableTimeSlots.isNotEmpty) ...[
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
                        itemCount: _availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final timeSlot = _availableTimeSlots[index];
                          final isSelected = timeSlot == _selectedTimeSlot;
                          final isBooked = _bookedTimeSlots.contains(timeSlot);

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
                                        _selectedTimeSlot = timeSlot;
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
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Please select a date',
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _selectedTimeSlot == null ? null : rescheduleAppointment,
          child: const Text('Reschedule Appointment'),
        ),
      ),
    );
  }
}
